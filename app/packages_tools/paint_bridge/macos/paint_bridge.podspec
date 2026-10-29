# The Rust core of Paintbox, built by cargokit before the app compiles.
Pod::Spec.new do |s|
  s.name             = 'paint_bridge'
  s.version          = '0.1.0'
  s.summary          = 'Paintbox core through flutter_rust_bridge.'
  s.description      = 'The paintbox_core Rust engine built as a static library.'
  s.homepage         = 'https://example.invalid/paintbox'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'Paintbox' => 'paintbox@example.invalid' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.swift_version = '5.0'

  s.script_phase = {
    :name => 'Build Rust library',
    # The crate folder relative to this one, then the library's name.
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../rust paintbox_bridge',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    :output_files => ["${BUILT_PRODUCTS_DIR}/libpaintbox_bridge.a"],
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '-force_load ${BUILT_PRODUCTS_DIR}/libpaintbox_bridge.a',
  }
end
