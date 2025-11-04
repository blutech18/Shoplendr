@echo off
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass shoplendr2024 -keypass shoplendr2024 -dname "CN=ShopLendr, OU=Development, O=ShopLendr, L=City, S=State, C=US"
