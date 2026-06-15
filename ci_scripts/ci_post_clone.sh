#!/bin/sh

# Xcode Cloud: post-clone.
# Instala CocoaPods y resuelve las dependencias (GoogleSignIn, ZIPFoundation)
# antes de compilar. Esto evita que Xcode Cloud tenga que pedir acceso a los
# repos de GitHub de las dependencias (google/*, openid/*, weichsel/*), que no
# son nuestros y no se pueden conceder.

set -e

export HOMEBREW_NO_INSTALL_CLEANUP=TRUE
export LANG=en_US.UTF-8

echo "==> Instalando CocoaPods y rsync…"
# rsync de Homebrew: macOS reciente trae openrsync, que rompe la copia de
# frameworks de CocoaPods. El post_install del Podfile fuerza este rsync.
brew install cocoapods rsync

echo "==> pod install…"
# Xcode Cloud ejecuta este script desde la carpeta ci_scripts;
# el Podfile está en la raíz del repositorio clonado.
cd "$CI_PRIMARY_REPOSITORY_PATH"
pod install

echo "==> Dependencias listas."
