ifeq ($(DSR),)
$(error Set $$DSR to your Dark Souls Remastered directory)
endif

# Use empty expression to force space
DSR := $(subst $(strip) ,\ ,$(DSR))

SRC_DIR := source/FRPG_FlverPBL
COMMON_DIR := source/Common
FLVER_OUT := $(DSR)/shader/FRPG_FlverPBL_fpo_DX11-shaderbnd-dcx
FLVER_DCX := $(DSR)/shader/FRPG_FlverPBL_fpo_DX11.shaderbnd.dcx
FLVER_ME2 := $(DSR)/ModEngine2/dsr-lighting/shader/FRPG_FlverPBL_fpo_DX11.shaderbnd.dcx

VARIANTS := $(foreach Spc,___ Spc, \
            $(foreach Bmp,___ Bmp, \
            $(foreach Mul,___ Mul, \
            $(foreach Lit,___ Lit, \
            $(foreach Sdw,___ Sdw Csd, \
            Dif$(Spc)$(Bmp)$(Mul)$(Lit)$(Sdw))))))

GST_VARIANTS := $(VARIANTS:=_HemEnv) \
                $(VARIANTS:=_HemEnvLerp) \
                $(VARIANTS:=_HemEnvLerpPntS) \
                $(VARIANTS:=_HemEnvPntS)

PHN_VARIANTS := $(VARIANTS:=_HemEnv) \
                $(VARIANTS:=_HemEnvLerp) \
                $(VARIANTS:=_HemEnvLerpParallax) \
                $(VARIANTS:=_HemEnvLerpPntS) \
                $(VARIANTS:=_HemEnvLerpSubsurf) \
                $(VARIANTS:=_HemEnvParallax) \
                $(VARIANTS:=_HemEnvPntS) \
                $(VARIANTS:=_HemEnvSubsurf)

SFX_VARIANTS := $(VARIANTS:=_HemEnv) \
                $(VARIANTS:=_HemEnvLerp) \
                $(VARIANTS:=_HemEnvLerpPntS) \
                $(VARIANTS:=_HemEnvPntS)

TARGET_NAMES := $(GST_VARIANTS:%=FRPG_Gst_%.fpo) \
                $(PHN_VARIANTS:%=FRPG_Phn_%.fpo) \
                $(SFX_VARIANTS:%=FRPG_Sfx_%.fpo)

TARGETS := $(foreach target,$(TARGET_NAMES),$(FLVER_OUT)/$(target))

DEFINES := _WIN32=1 _FRAGMENT_SHADER=1 _DX11=1
FXCFLAGS = //Tps_5_0 //nologo $(foreach define,$(DEFINES),//D$(define))

SOURCES := $(shell find $(SRC_DIR) $(COMMON_DIR) -type f 2> /dev/null)

.PHONY: all
all: $(FLVER_ME2)

.PHONY: test
test: STEAM := "$(shell echo $(DSR) | grep -Poh '.*/Steam(?=/steamapps)')/steam.exe"
test: APPID := 570940
test: all
	@echo "Launching Dark Souls Remastered"
	@$(STEAM) -applaunch $(APPID)

$(FLVER_ME2): $(FLVER_DCX)
	@cp "$<" "$@"

$(FLVER_DCX): $(TARGETS)
	@Yabber $(FLVER_OUT)

$(FLVER_OUT):
	@Yabber $(FLVER_DCX)

add_variant = $(foreach name,$(TARGET_NAMES), \
	$(if $(findstring $(strip $1),$(name)),$(FLVER_OUT)/$(name),)): DEFINES += $(strip $2)

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

$(FLVER_OUT)/FRPG_Gst_%.fpo: DEFINES += WITH_GhostMap
$(FLVER_OUT)/FRPG_Sfx_%.fpo: DEFINES += WITH_Glow

$(FLVER_OUT)/FRPG_%.fpo: OUT_OBJ = $(subst /,\\,$@)
$(FLVER_OUT)/FRPG_%.fpo: OUT_ASM = $(OUT_OBJ:.fpo=.asm)

$(FLVER_OUT)/FRPG_%.fpo: $(SOURCES) $(FLVER_OUT)
	@fxc $(SRC_DIR)/FRPG_FS_HemEnv.fx "//Fo$(OUT_OBJ)" "//Fc$(OUT_ASM)" $(FXCFLAGS) //EFragmentMain