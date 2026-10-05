from Crypto.Cipher import AES


# --------------------------------------------------
# Read plaintext and key from file
# --------------------------------------------------

with open("key.txt", "r") as file:

    data_hex = file.readline().strip()    # Read plaintext hex string
    key_hex  = file.readline().strip()    # Read key hex string


# --------------------------------------------------
# Convert hexadecimal strings to bytes
# --------------------------------------------------

data = bytes.fromhex(data_hex)
key  = bytes.fromhex(key_hex)


# --------------------------------------------------
# AES Encryption
# --------------------------------------------------

cipher = AES.new(key, AES.MODE_ECB)

ciphertext = cipher.encrypt(data)


# --------------------------------------------------
# Write ciphertext to output file
# --------------------------------------------------

with open("Ref_Data.txt", "w") as file:

    file.write(ciphertext.hex())