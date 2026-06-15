# Podfile de FacturaInvent (v1)
# Las dependencias se gestionan con CocoaPods (no SPM) para que Xcode Cloud
# pueda construir el proyecto sin pedir acceso a repos de GitHub ajenos
# (google/*, openid/*, weichsel/*). Ver ci_scripts/ci_post_clone.sh.
#
# Actualizar versiones con:  pod update

platform :ios, '26.0'

# Hay varios .xcodeproj en la carpeta; fijamos el correcto.
project 'FacturaInvent.xcodeproj'

target 'FacturaInvent' do
  use_frameworks!

  pod 'GoogleSignIn', '9.1.0'
  pod 'ZIPFoundation', '0.9.20'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '26.0'
    end
  end

  # Workaround: macOS 15+/26 reemplaza /usr/bin/rsync por openrsync, que rompe
  # los scripts de copia de frameworks/recursos de CocoaPods con el error
  # "unexpected end of file". Anteponemos el rsync de Homebrew (samba) en el PATH
  # de esos scripts. Requiere `brew install rsync` (local y en Xcode Cloud via
  # ci_scripts/ci_post_clone.sh). Se reaplica en cada `pod install`.
  support_dir = File.join(installer.sandbox.root, 'Target Support Files', 'Pods-FacturaInvent')
  %w[Pods-FacturaInvent-frameworks.sh Pods-FacturaInvent-resources.sh].each do |name|
    script = File.join(support_dir, name)
    next unless File.exist?(script)
    contents = File.read(script)
    inject = %Q(export PATH="/opt/homebrew/bin:$PATH"\n)
    next if contents.include?(inject)
    contents = contents.sub(/\A(#!.*\n)/, "\\1#{inject}")
    File.write(script, contents)
  end
end
