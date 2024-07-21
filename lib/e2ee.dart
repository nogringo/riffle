import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bip39/bip39.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

String mnemonic = generateMnemonic(strength: 256);

Key generateEncryptionKey() {
  final random = Random.secure();
  final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
  return Key(Uint8List.fromList(keyBytes));
}

Key generateKey(String keyString) {
  return Key.fromUtf8(
      sha256.convert(utf8.encode(keyString)).toString().substring(0, 32));
}

IV generateIV() {
  return IV.fromLength(16);
}

String encryptText(String text, String keyString) {
  final key = generateKey(keyString);
  final iv = generateIV();
  final encrypter = Encrypter(AES(key));
  final encrypted = encrypter.encrypt(text, iv: iv);

  // Combine IV and encrypted text
  final combined = iv.base64 + encrypted.base64;
  return combined;
}

String decryptText(String encryptedText, String keyString) {
  final key = generateKey(keyString);

  // Extract IV and encrypted text
  final iv = IV.fromBase64(encryptedText.substring(0, 24));
  final encrypted = encryptedText.substring(24);

  final encrypter = Encrypter(AES(key));
  final decrypted = encrypter.decrypt64(encrypted, iv: iv);
  return decrypted;
}