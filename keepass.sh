#!/bin/bash
#===================================================================================
#
#         FILE: keepass.sh
#
#        USAGE: Run script
#
#  DESCRIPTION: Install KeePass in Fedora distribution.
#
# DEPENDENCIES: wget unzip mono-core mono-winforms.
# REQUIREMENTS: Administrator rights 
#
#       AUTHOR: Liudas Alisauskas, liudas@akmc.lt
#      LICENCE: GPL v2
#
#      VERSION: 2.27-1
#      CREATED: 2014-03-28
#     REVISION: 2014-07-23
#===================================================================================

# Settings
#language='Lithuanian'		# Comment out and define language if you want you translations to be downloaded
version='2.29'				# KeePass version
in_path='/opt'				# Define installation path UP TO folder 'keepass'. Better leave as it is

dep=(unzip mono-core mono-winforms xdotool)	# Array of dependencies

clear
echo "--> Cheking for dependencies: ${dep[@]}"
echo "--> Missing will be installed automatically"
echo
sleep 1
# Ckech if dependecy package is installed. If not - install
for dep_check in ${dep[@]}; do
	if rpm -q ${dep_check} | grep -q not; then
		echo Package "\"${dep_check}\" - missing... Installing:"
		sudo dnf install ${dep_check} -y >/dev/null 2>&1
	else
		echo Package "\"${dep_check}\" - OK"
	fi
done

# Let's do all job in temporary folder
mkdir tmp
cd tmp

# Download KeePass and icon
echo
echo "--> Downloading KeePass ${version} source file"
echo
curl -s -L http://sourceforge.net/projects/keepass/files/KeePass%202.x/${version}/KeePass-${version}.zip/download > keepass.zip
echo "--> Downloading KeePass icon"
echo
curl -s http://upload.wikimedia.org/wikipedia/commons/1/19/KeePass_icon.png > keepass.png

# Download translation for language if defined; else skip this step
if [[ -n "${language}" ]]; then 
echo "--> Downloading KeePass translation file for ${language} language"
echo
curl -s -L http://sourceforge.net/projects/keepass/files/Translations%202.x/${version}/KeePass-${version}-${language}.zip/download > language.zip 
fi

unzip "*.zip" -d keepass >/dev/null 2>&1	# Extract files into keepass folder
rm keepass/{*.dll,*Util.exe}				# Remove some unnecessary files
mv keepass.png keepass/						# Move icon into app folder

# Create desktop file for KeePass
cat > keepass.desktop << EOF
[Desktop Entry]
Comment=The free, open source, light-weight and easy-to-use password manager
Comment[lt]=Laisva, atviro kodo, maža ir lengva naudoti slaptažodžių tvarkytuvė
GenericName=Cross-platform password manager
GenericName[lt]=Įvairiose platformose veikianti slaptažodžių tvarkytuvė
Name=KeePass Password Safe
Name[lt]=KeePass slaptažodžių saugykla
Exec=keepass
Icon=${in_path}/keepass/keepass.png
NoDisplay=false
StartupNotify=true
Terminal=0
Type=Application
Categories=Utility;System;
EOF

# Create executable file (launcher)
cat > keepass.bin << EOF
#!/bin/sh
exec mono ${in_path}/keepass/KeePass.exe
EOF

# Check for old existing files and if positive - remove
if [[ -s "/usr/bin/keepass" ]]; then sudo rm /usr/bin/keepass; fi
if [[ -s "${in_path}/keepass" ]]; then sudo rm -rf ${in_path}/keepass; fi
if [[ -s "/usr/share/applications/keepass.desktop" ]]; then sudo rm /usr/share/applications/keepass.desktop; fi
# Copy new files 
sudo cp keepass.bin /usr/bin/keepass
sudo chmod 755 /usr/bin/keepass
sudo cp -R keepass ${in_path}/
sudo cp keepass.desktop /usr/share/applications/

cd ..

rm -rf tmp	# Remove temporary folder
echo
echo "--> Done! Go to your menu and check for KeePass ${version}"
if [[ -n "${language}" ]]; then # Print language change instructions if language was defined
	echo "--> Change KeePass interface language: View - Change language - ${language}"
	echo
fi
