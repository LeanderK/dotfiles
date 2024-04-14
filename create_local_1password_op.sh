#installs 1password locally, for example on a server where you don't have root access

ARCH="<choose between 386/amd64/arm/arm64>"
wget "https://cache.agilebits.com/dist/1P/op2/pkg/v2.26.1/op_linux_amd64_v2.26.1.zip" -O op.zip
unzip -d op op.zip
if [ ! -d ~/bin ]; then
    mkdir ~/bin
fi
mv op/op ~/bin
rm -r op.zip op