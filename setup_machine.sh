
# Install QUICHE
cd ~/.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
git clone --recursive https://github.com/cloudflare/quiche && cd quiche
git checkout c629ef2574d5a4645b9d4ee09117eacf9cffc51a
cargo build --examples


# MSQUIC steps

# install cmake
cd ~/.
sudo apt-get purge -y cmake
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ bionic main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
sudo apt-get update
sudo rm /usr/share/keyrings/kitware-archive-keyring.gpg
sudo apt-get install -y kitware-archive-keyring
sudo apt-get install -y cmake

# install dotnet
wget https://download.visualstudio.microsoft.com/download/pr/1d2007d3-da35-48ad-80cc-a39cbc726908/1f3555baa8b14c3327bb4eaa570d7d07/dotnet-sdk-6.0.403-linux-x64.tar.gz
mkdir -p $HOME/dotnet && tar zxf dotnet-sdk-6.0.403-linux-x64.tar.gz -C $HOME/dotnet
echo "export DOTNET_ROOT=\$HOME/dotnet" >> ~/.bashrc
echo "export PATH=\$PATH:\$HOME/dotnet" >> ~/.bashrc
source ~/.bashrc

# download msquic
cd ~/.
git clone --recursive https://github.com/microsoft/msquic.git && cd msquic
git checkout 7d921b72df11d94cbc9ee21a6b4fede21d3e9ad3

# install the dependencies
sudo apt-add-repository ppa:lttng/stable-2.12
sudo apt-get update
sudo apt-get install -y build-essential liblttng-ust-dev lttng-tools gdb


sudo sh -c "echo 'root soft core unlimited' >> /etc/security/limits.conf"
sudo sh -c "echo 'root hard core unlimited' >> /etc/security/limits.conf"
sudo sh -c "echo '* soft core unlimited' >> /etc/security/limits.conf"
sudo sh -c "echo '* hard core unlimited' >> /etc/security/limits.conf"
sudo sh -c "echo -n '%e.%p.%t.core' > /proc/sys/kernel/core_pattern"


# add clog2text
dotnet build submodules/clog
dotnet tool update --global --add-source submodules/clog/src/nupkg "Microsoft.Logging.CLOG2Text.Lttng"

mkdir build && cd build
cmake -G 'Unix Makefiles' -DQUIC_TLS=openssl -DQUIC_OUTPUT_DIR="$HOME/msquic/artifacts/bin/linux/x64_Debug_openssl" -DQUIC_LINUX_LOG_ENCODER=lttng -DQUIC_ENABLE_LOGGING=on -DQUIC_BUILD_TOOLS=on -DQUIC_BUILD_TEST=on -DQUIC_BUILD_PERF=on -DCMAKE_BUILD_TYPE=Debug -DQUIC_LIBRARY_NAME=msquic -S ..
cmake --build .
