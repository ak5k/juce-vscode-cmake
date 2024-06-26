# If you've installed JUCE somehow (via a package manager, or directly using the CMake install
# target), you'll need to tell this project that it depends on the installed copy of JUCE. If you've
# included JUCE directly in your source tree (perhaps as a submodule), you'll need to tell CMake to
# include that subdirectory as part of the build.

# find_package(JUCE CONFIG REQUIRED)        # If you've installed JUCE to your system
# or
add_subdirectory(JUCE)                    # If you've put JUCE in a subdirectory called JUCE

# If you are building a VST2 or AAX plugin, CMake needs to be told where to find these SDKs on your
# system. This setup should be done before calling `juce_add_plugin`.

# juce_set_vst2_sdk_path(...)
# juce_set_aax_sdk_path(...)

# `juce_add_plugin` adds a static library target with the name passed as the first argument
# (AudioPluginExample here). This target is a normal CMake target, but has a lot of extra properties set
# up by default. As well as this shared code static library, this function adds targets for each of
# the formats specified by the FORMATS arguments. This function accepts many optional arguments.
# Check the readme at `docs/CMake API.md` in the JUCE repo for the full list.

juce_add_plugin(${PROJECT_NAME}
  # VERSION ...                               # Set this if the plugin version is different to the project version
  # ICON_BIG ...                              # ICON_* arguments specify a path to an image file to use as an icon for the Standalone
  # ICON_SMALL ...
  # COMPANY_NAME ...                          # Specify the name of the plugin's author
  # IS_SYNTH TRUE/FALSE                       # Is this a synth or an effect?
  # NEEDS_MIDI_INPUT TRUE/FALSE               # Does the plugin need midi input?
  # NEEDS_MIDI_OUTPUT TRUE/FALSE              # Does the plugin need midi output?
  # IS_MIDI_EFFECT TRUE/FALSE                 # Is this plugin a MIDI effect?
  # EDITOR_WANTS_KEYBOARD_FOCUS TRUE/FALSE    # Does the editor need keyboard focus?
  COPY_PLUGIN_AFTER_BUILD TRUE/FALSE          # Should the plugin be installed to a default location after building?
  PLUGIN_MANUFACTURER_CODE Juce               # A four-character manufacturer id with at least one upper-case character
  PLUGIN_CODE Dem0                            # A unique four-character plugin id with exactly one upper-case character
                                              # GarageBand 10.3 requires the first letter to be upper-case, and the remaining letters to be lower-case
  FORMATS AU VST3 Standalone                  # The formats to build. Other valid formats are: AAX Unity VST AU AUv3
  PRODUCT_NAME ${PROJECT_NAME})               # The name of the final executable, which can differ from the target name

# `juce_generate_juce_header` will create a JuceHeader.h for a given target, which will be generated
# into your build tree. This should be included with `#include <JuceHeader.h>`. The include path for
# this header will be automatically added to the target. The main function of the JuceHeader is to
# include all your JUCE module headers; if you're happy to include module headers directly, you
# probably don't need to call this.

juce_generate_juce_header(${PROJECT_NAME})

# `target_sources` adds source files to a target. We pass the target that needs the sources as the
# first argument, then a visibility parameter for the sources which should normally be PRIVATE.
# Finally, we supply a list of source files that will be built into the target. This is a standard
# CMake command.

# `target_compile_definitions` adds some preprocessor definitions to our target. In a Projucer
# project, these might be passed in the 'Preprocessor Definitions' field. JUCE modules also make use
# of compile definitions to switch certain features on/off, so if there's a particular feature you
# need that's not on by default, check the module header for the correct flag to set here. These
# definitions will be visible both to your code, and also the JUCE module code, so for new
# definitions, pick unique names that are unlikely to collide! This is a standard CMake command.

target_compile_definitions(${PROJECT_NAME} PUBLIC
    JUCE_ALSA=1
    JUCE_CONTENT_SHARING=1
    JUCE_DIRECTSOUND=1
    JUCE_DISABLE_CAUTIOUS_PARAMETER_ID_CHECKING=1
    JUCE_PLUGINHOST_LADSPA=1
    JUCE_PLUGINHOST_LV2=1
    JUCE_PLUGINHOST_VST3=1
    JUCE_PLUGINHOST_VST=0
    JUCE_PLUGINHOST_ARA=0
    JUCE_USE_CAMERA=0
    JUCE_USE_CDBURNER=0
    JUCE_USE_CDREADER=0
    JUCE_USE_CURL=0
    JUCE_USE_FLAC=0
    JUCE_USE_OGGVORBIS=1
    JUCE_VST3_HOST_CROSS_PLATFORM_UID=1
    JUCE_VST3_CAN_REPLACE_VST2=0
    JUCE_WASAPI=1
    JUCE_WEB_BROWSER=0
    PIP_JUCE_EXAMPLES_DIRECTORY_STRING="${JUCE_SOURCE_DIR}/examples"
    # This is a temporary workaround to allow builds to complete on Xcode 15.
    # Add -Wl,-ld_classic to the OTHER_LDFLAGS build setting if you need to
    # deploy to older versions of macOS/iOS.
    JUCE_SILENCE_XCODE_15_LINKER_WARNING=1)

# If your target needs extra binary assets, you can add them here. The first argument is the name of
# a new static library target that will include all the binary resources. There is an optional
# `NAMESPACE` argument that can specify the namespace of the generated binary data class. Finally,
# the SOURCES argument should be followed by a list of source files that should be built into the
# static library. These source files can be of any kind (wav data, images, fonts, icons etc.).
# Conversion to binary-data will happen when your target is built.

# juce_add_binary_data(AudioPluginData SOURCES ...)

# `target_link_libraries` links libraries and JUCE modules to other libraries or executables. Here,
# we're linking our executable target to the `juce::juce_audio_utils` module. Inter-module
# dependencies are resolved automatically, so `juce_core`, `juce_events` and so on will also be
# linked automatically. If we'd generated a binary data target above, we would need to link to it
# here too. This is a standard CMake command.

target_link_libraries(${PROJECT_NAME}
  PRIVATE
    # AudioPluginData           # If we'd created a binary data target, we'd link to it here
    juce::juce_audio_utils
    juce::juce_dsp
  PUBLIC
    juce::juce_recommended_config_flags
    juce::juce_recommended_lto_flags
    juce::juce_recommended_warning_flags)