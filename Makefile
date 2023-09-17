ifeq ($(DSR),)
$(error Set $$DSR to your Dark Souls Remastered directory)
endif

# Use empty expression to force space
DSR := $(subst $(strip) ,\ ,$(DSR))

SRC_DIR := source/FRPG_FlverPBL
COMMON_DIR := source/Common
FLVER_OUT := $(DSR)/shader/FRPG_FlverPBL_fpo_DX11-shaderbnd-dcx
FLVER_DCX := $(DSR)/shader/FRPG_FlverPBL_fpo_DX11.shaderbnd.dcx

VARIANTS := $(foreach Spc,___ Spc, \
            $(foreach Bmp,___ Bmp, \
            $(foreach Mul,___ Mul, \
            $(foreach Lit,___ Lit, \
            $(foreach Sdw,___ Sdw Csd, \
            Dif$(Spc)$(Bmp)$(Mul)$(Lit)$(Sdw))))))

SFX_VARIANTS := $(patsubst %,%_HemEnv,$(VARIANTS)) \
                $(patsubst %,%_HemEnvLerp,$(VARIANTS)) \
                $(patsubst %,%_HemEnvLerpPntS,$(VARIANTS)) \
                $(patsubst %,%_HemEnvPntS,$(VARIANTS))

PHN_VARIANTS := $(patsubst %,%_HemEnv,$(VARIANTS)) \
                $(patsubst %,%_HemEnvLerp,$(VARIANTS)) \
                $(patsubst %,%_HemEnvLerpParallax,$(VARIANTS)) \
                $(patsubst %,%_HemEnvLerpPntS,$(VARIANTS)) \
                $(patsubst %,%_HemEnvLerpSubsurf,$(VARIANTS)) \
                $(patsubst %,%_HemEnvParallax,$(VARIANTS)) \
                $(patsubst %,%_HemEnvPntS,$(VARIANTS)) \
                $(patsubst %,%_HemEnvSubsurf,$(VARIANTS))

TARGET_NAMES := $(patsubst %,FRPG_Sfx_%.fpo,$(SFX_VARIANTS)) \
                $(patsubst %,FRPG_Phn_%.fpo,$(PHN_VARIANTS))

TARGETS := $(foreach target,$(TARGET_NAMES),$(FLVER_OUT)/$(target))

DEFINES := //D_WIN32=1 //D_FRAGMENT_SHADER=1 //D_DX11=1
FXCFLAGS = //Tps_5_0 $(DEFINES) //nologo

SOURCES := $(shell find $(SRC_DIR) $(COMMON_DIR) -type f 2> /dev/null)

.PHONY: all
all: $(FLVER_DCX)

.PHONY: test
test: STEAM := "$(shell echo $(DSR) | grep -Poh '.*/Steam(?=/steamapps)')/steam.exe"
test: APPID := 570940
test: all
	@echo "Launching Dark Souls Remastered"
	@$(STEAM) -applaunch $(APPID)

$(FLVER_DCX): $(TARGETS)
	@Yabber $(FLVER_OUT)

$(FLVER_OUT):
	@Yabber $(FLVER_DCX)

$(FLVER_OUT)/FRPG_%.fpo: $(SOURCES) $(FLVER_OUT)
	@fxc $(SRC_DIR)/FRPG_FS_HemEnv.fx "//Fo$(subst /,\\,$@)" $(FXCFLAGS) //EFragmentMain

add_variant = $(foreach name,$(TARGET_NAMES), \
	$(if $(findstring $(strip $1),$(name)),$(FLVER_OUT)/$(name),)): DEFINES += //D$(strip $2)

$(call add_variant, Spc, WITH_SpecularMap)
$(call add_variant, Bmp, WITH_BumpMap)
$(call add_variant, Mul, WITH_MultiTexture)
$(call add_variant, Lit, WITH_LightMap)
$(call add_variant, Sdw, WITH_ShadowMap=1)
$(call add_variant, Csd, WITH_ShadowMap=2)

$(call add_variant, Lerp,     WITH_EnvLerp)
$(call add_variant, Parallax, WITH_Parallax)
$(call add_variant, PntS,     WITH_PntS)
$(call add_variant, Subsurf,  FS_SUBSURF)

$(FLVER_OUT)/FRPG_Sfx_%.fpo: DEFINES += //DWITH_Glow