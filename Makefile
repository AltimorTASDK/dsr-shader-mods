ifeq ($(DSR),)
$(error Set $$DSR to your Dark Souls Remastered directory)
endif

# Use empty expression to force space
DSR := $(subst $(strip) ,\ ,$(DSR))

SRC_DIR := source/FRPG_FlverPBL
COMMON_DIR := source/Common
FLVER_OUT := $(DSR)/FRPG_FlverPBL_fpo_DX11-shaderbnd-dcx
FLVER_DCX := $(DSR)/FRPG_FlverPBL_fpo_DX11.shaderbnd.dcx

VARIANTS := $(shell grep -Poh '(?<=FragmentMain_)[^()]+' '$(SRC_DIR)/FRPG_FS_HemEnv_Base.fxh')

SFX_VARIANTS := $(VARIANTS) \
                $(patsubst %,%_HemEnv,$(VARIANTS)) \
                $(patsubst %,%_HemEnvLerp,$(VARIANTS))

PHN_VARIANTS := $(patsubst %,%_HemEnv,$(VARIANTS)) \
                $(patsubst %,%_HemEnvLerp,$(VARIANTS)) \
                $(patsubst %,%_HemEnvSubsurf,$(VARIANTS)) \
                $(patsubst %,%_HemEnvLerpSubsurf,$(VARIANTS))

TARGETS := $(patsubst %,$(FLVER_OUT)/FRPG_Sfx_%.fpo,$(SFX_VARIANTS)) \
           $(patsubst %,$(FLVER_OUT)/FRPG_Phn_%.fpo,$(PHN_VARIANTS))

DEFINES := //D_WIN32=1 //D_FRAGMENT_SHADER=1 //D_DX11=1
FXCFLAGS := //Tps_5_0 $(DEFINES) //nologo

SOURCES := $(shell find $(SRC_DIR) $(COMMON_DIR) -type f 2> /dev/null)

.PHONY: all
all: $(FLVER_DCX)

.PHONY: test
test: STEAM := "$(shell echo $(DSR) | grep -Poh '.*/Steam(?=/steamapps)')/steam.exe"
test: APPID := 570940
test: all
	@echo "Launching Dark Souls Remastered"
	@$(STEAM) -applaunch $(APPID)

$(FLVER_DCX): $(FLVER_OUT) $(TARGETS)
	@Yabber $(FLVER_OUT)

$(FLVER_OUT):
	@Yabber $(FLVER_DCX)

# Sfx
$(FLVER_OUT)/FRPG_Sfx_%.fpo: $(SOURCES)
	@fxc $(SRC_DIR)/FRPG_FS_SFX.fx "//Fo$(subst /,\\,$@)" $(FXCFLAGS) //EFragmentMain_$*

$(FLVER_OUT)/FRPG_Sfx_%_HemEnv.fpo: $(SOURCES)
	@fxc $(SRC_DIR)/FRPG_FS_HemEnv.fx "//Fo$(subst /,\\,$@)" $(FXCFLAGS) //EFragmentMain_$*

$(FLVER_OUT)/FRPG_Sfx_%_HemEnvLerp.fpo: $(FLVER_OUT)/FRPG_Sfx_%_HemEnv.fpo
	cp "$<" "$@"

# Phn
$(FLVER_OUT)/FRPG_Phn_%_HemEnv.fpo: $(SOURCES)
	@fxc $(SRC_DIR)/FRPG_FS_PHN.fx "//Fo$(subst /,\\,$@)" $(FXCFLAGS) //EFragmentMain_$*

$(FLVER_OUT)/FRPG_Phn_%_HemEnvLerp.fpo: $(FLVER_OUT)/FRPG_Phn_%_HemEnv.fpo
	cp "$<" "$@"

$(FLVER_OUT)/FRPG_Phn_%_HemEnvSubsurf.fpo: $(FLVER_OUT)/FRPG_Phn_%_HemEnv.fpo
	@fxc $(SRC_DIR)/FRPG_FS_PHN.fx "//Fo$(subst /,\\,$@)" $(FXCFLAGS) //DFS_SUBSURF //EFragmentMain_$*

$(FLVER_OUT)/FRPG_Phn_%_HemEnvLerpSubsurf.fpo: $(FLVER_OUT)/FRPG_Phn_%_HemEnvSubsurf.fpo
	cp "$<" "$@"