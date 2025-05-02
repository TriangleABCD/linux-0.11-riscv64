# 目录变量
TOP_DIR:= $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))
CUR_DIR:= $(CURDIR)

# 交叉编译工具链
CROSS_COMPILE:= riscv64-unknown-elf-
CC:= $(CROSS_COMPILE)gcc
LD:= $(CROSS_COMPILE)ld
OBJCOPY:= $(CROSS_COMPILE)objcopy
OBJDUMP:= $(CROSS_COMPILE)objdump

# QEMU 选项
QEMU:= qemu-system-riscv64
CPUS:= 1
MEM:= 512M
QEMU_FLAGS:= -bios default -smp $(CPUS) -nographic -M virt -m $(MEM)

# 源文件和目标文件
SRC_DIR:= $(TOP_DIR)/src
BUILD_DIR:= $(TOP_DIR)/build
OUT_DIR:= $(TOP_DIR)/out

SRC:= $(shell find $(SRC_DIR) -name "*.s")
SRC:= $(shell find $(SRC_DIR) -name "*.S")
SRC+= $(shell find $(SRC_DIR) -name "*.c")

OBJS:= $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC))
OBJS:= $(patsubst $(SRC_DIR)/%.s, $(BUILD_DIR)/%.o, $(OBJS))
OBJS:= $(patsubst $(SRC_DIR)/%.S, $(BUILD_DIR)/%.o, $(OBJS))

INCLUDE_FLAG:= -I$(TOP_DIR)/src/include

CFLAGS:= -mcmodel=medany -std=gnu99 -Wno-unused -Werror
CFLAGS+= -fno-builtin -Wall -O2 -nostdinc
CFLAGS+= -fno-stack-protector -ffunction-sections -fdata-sections
CFLAGS+= -ffreestanding
CFLAGS+= $(INCLUDE_FLAG)

LDFLAGS:= -m elf64lriscv
LDFLAGS+= -nostdlib --gc-sections
LD_SCIPT:= $(TOP_DIR)/platform/qemu-opensbi.ld

NAME:= kernel
ELF:= $(NAME).elf
IMG:= $(NAME).img

################################################################

$(IMG): $(ELF)
	@mkdir -p $(OUT_DIR)
	$(OBJCOPY) $(OUT_DIR)/$(ELF) --strip-all -O binary $(OUT_DIR)/$@

$(ELF): $(OBJS)
	@mkdir -p $(OUT_DIR)
	$(LD) $^ -o $(OUT_DIR)/$@ $(LDFLAGS) -T $(LD_SCIPT)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

qemu: $(IMG)
	# $(QEMU) $(QEMU_FLAGS) -device loader,file=$(OUT_DIR)/$(IMG),addr=0x80200000
	$(QEMU) $(QEMU_FLAGS) -kernel $(OUT_DIR)/$(ELF)

clean:
	rm -rf $(BUILD_DIR)	$(OUT_DIR)

.PHONY: qemu clean
