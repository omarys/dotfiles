sudo mkdir /usr/lib/vmware/view/pkcs11/ # frames folder for next step
if [[ "$(uname -n)" = "fedora" ]]; then
	sudo ln -s /usr/lib64/pkcs11/onepin-opensc-pkcs11.so /usr/lib/vmware/view/pkcs11/libopenscpkcs11.so         # symbolic link from the security device firefox is using correctly to what vmware expects to use, can change onepin-opensc-pkcs11.so with whatever is correctly being used for NSS pin prompting
else                                                                                                         # Debian-based systems have different location for libraries
	sudo ln -s /usr/lib/x86_64-linux-gnu/onepin-opensc-pkcs11.so /usr/lib/vmware/view/pkcs11/libopenscpkcs11.so # symbolic link from the security device firefox is using correctly to what vmware expects to use, can change onepin-opensc-pkcs11.so with whatever is correctly being used for NSS pin prompting
fi
