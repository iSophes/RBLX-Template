# Sophie's Project Template

This is a template I use to begin my projects, mainly so I don't have to spend a day writing the same stuff again.

# NOTE: THIS PROJECT IS ADAPTED FOR MY USE

However, feel free to edit it and fork how you want.

# Installation

Note: This installation uses Bash, for windows you need to use a Git Bash CLI 

Note: Not all tools will be installed here, some tools are required, such as Git, Rokit and wally-package-types 

1. Clone the repo

```sh
git clone https://github.com/isophes/RBLX-Template && cd RBLX-Template
```

2. Edit "install-packages.sh" to point wally-package-types to where you
have wally-package types

3. Install packages

```sh
rokit install && sh install-packages.sh
```

4. Build place and serve!

```sh
rojo build -o game.rbxl && rojo serve
```