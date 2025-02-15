#!/bin/bash

wget https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-linux.zip
sudo unzip ninja-linux.zip -d /usr/local/bin/
sudo rm ninja-linux.zip
sudo update-alternatives --install /usr/bin/ninja ninja /usr/local/bin/ninja 1 --force