PROJECT = camera

# please refer to the followings for more information:
#   https://stackoverflow.com/a/30142139/2604712
#       > Makefile, header dependencies
#   https://www.gnu.org/software/make/manual/html_node/Text-Functions.html
#   https://devhints.io/makefile
#   https://bytes.usc.edu/cs104/wiki/makefile/
#   https://stackoverflow.com/a/3477400/2604712
#       > What do @, - and + do as prefixes to recipe lines in Make?

TOOLCHAIN ?= or1k-elf
CC = $(TOOLCHAIN)-gcc
LD = $(TOOLCHAIN)-ld
ELF2MEM ?= convert_or32
DEBUG ?= 0

CFLAGS ?=
LDFLAGS ?=

_LDFLAGS += -nostartfiles -fdata-sections -ffunction-sections -Wl,--gc-sections
_CFLAGS += -MMD -DPRINTF_INCLUDE_CONFIG_H -I include/ -I support/include

ifeq ($(DEBUG), 1)
BUILD = build-debug
_CFLAGS += -Og -g
else
BUILD = build-release
_CFLAGS +=  
endif


# User sources go in the src/ directory
# Support files go in the support/src/ directory

CSRCS = $(wildcard src/*.c) $(wildcard support/src/*.c)
SSRCS = $(wildcard src/*.s) $(wildcard support/src/*.s)

OBJS = $(SSRCS:%.s=$(BUILD)/%.s.o) $(CSRCS:%.c=$(BUILD)/%.c.o)

ELF = $(addsuffix .elf,$(BUILD)/$(PROJECT))
MEM = $(addsuffix .mem,$(BUILD)/$(PROJECT))

mem1300: TARGET=__OR1300__
mem1300: EXT=.or1300
mem1300: _CFLAGS += -Os -D__OR1300__
mem1300: clean $(MEM)

mem1420: TARGET=__OR1420__
mem1420: EXT=.or1420
mem1420: _CFLAGS += -Os -msoft-div
mem1420: clean $(MEM)

elf : $(ELF)


$(MEM) : crt0def.inc $(ELF)
	mkdir -p $(@D)
	cd $(BUILD); \
		$(ELF2MEM) $(addsuffix .elf,$(PROJECT)); \
		mv $(addsuffix .elf.mem,$(PROJECT)) $(addsuffix $(EXT).mem,$(PROJECT)); \
		mv $(addsuffix .elf.cmem,$(PROJECT)) $(addsuffix $(EXT).cmem,$(PROJECT))

$(ELF) : $(OBJS)
	mkdir -p $(@D)
	$(CC) $(_LDFLAGS) $(LDFLAGS) $^ -o $@;
	

crt0def.inc:
	echo ".set $(TARGET),1" > crt0def.inc

# user source code
$(BUILD)/src/%.c.o : src/%.c
	mkdir -p $(@D)
	$(CC) $(_CFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD)/src/%.s.o : src/%.s
	mkdir -p $(@D)
	$(CC) $(_CFLAGS) $(CFLAGS) -c $< -o $@

# for support
$(BUILD)/support/src/%.c.o : support/src/%.c
	mkdir -p $(@D)
	$(CC) $(_CFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD)/support/src/%.s.o : support/src/%.s
	mkdir -p $(@D)
	$(CC) $(_CFLAGS) $(CFLAGS) -c $< -o $@

.PHONY : clean

clean :
	-rm -rf $(BUILD)/* crt0def.inc
