// SIO = the RP2040’s single-cycle I/O block.
// Reference documentation: https://datasheets.raspberrypi.com/rp2040/rp2040-datasheet.pdf#tab-registerlist_sio
let SIO_BASE: UInt = 0xd0000000
let SIO_GPIO_OUT_SET_OFFSET: Int = 0x00000014
let SIO_GPIO_OUT_CLR_OFFSET: Int = 0x00000018

let I2C_BAUDRATE: UInt = 100_000
let I2C_SLAVE_ADDRESS: UInt = 0x17

let I2C_SLAVE_SCL_PIN: UInt = PICO_DEFAULT_I2C_SCL_PIN
let I2C_SLAVE_SDA_PIN: UInt = PICO_DEFAULT_I2C_SDA_PIN

struct PicoI2CContext {
    var mem: (UInt8, UInt8, UInt8) = (0, 0, 0)
    var mem_address: UInt8 = 0
    var mem_address_written: Bool = false
}
var context = PicoI2CContext()

func i2c_slave_handler(i2c: UnsafePointer<i2c_inst_t>, event: UnsafePointer<i2c_slave_event>) {
    switch event {
        case I2C_SLAVE_RECEIVE:
            if (!context.mem_address_written) {
                // writes always start with the memory address
                context.mem_address = i2c_read_byte_raw(i2c);
                context.mem_address_written = true;
            } else {
                // save into memory
                context.mem[context.mem_address] = i2c_read_byte_raw(i2c);
                context.mem_address += 1;
            }
        case I2C_SLAVE_REQUEST:
            // load from memory
            i2c_write_byte_raw(i2c, context.mem[context.mem_address]);
            context.mem_address += 1;
        case I2C_SLAVE_FINISH:
            context.mem_address_written = false
    }
}

func setup_slave() {
    gpio_init(I2C_SLAVE_SDA_PIN);
    gpio_set_function(I2C_SLAVE_SDA_PIN, GPIO_FUNC_I2C);
    gpio_pull_up(I2C_SLAVE_SDA_PIN);

    gpio_init(I2C_SLAVE_SCL_PIN);
    gpio_set_function(I2C_SLAVE_SCL_PIN, GPIO_FUNC_I2C);
    gpio_pull_up(I2C_SLAVE_SCL_PIN);

    i2c_init(i2c0, I2C_BAUDRATE);
    // configure I2C0 for slave mode
    i2c_slave_init(i2c0, I2C_SLAVE_ADDRESS, &i2c_slave_handler);
}

@_cdecl("swiftlib_ledOnDuration")
public func ledOnDuration() -> UInt32 {
    200
}

@_cdecl("swiftlib_ledOffDuration")
public func ledOffDuration() -> UInt32 {
    400
}

/// Drive a GPIO output pin high or low.
///
/// - Warning: The goal of this is to demonstrate that Swift can access the
///   MCU's memory-mapped registers directly. But this isn't safe because Swift
///   doesn't support volatile memory access yet. The actual read and write
///   must happen in C (this is also how
///   [Swift-MMIO](https://github.com/apple/swift-mmio) does it).
@_cdecl("swiftlib_gpioSet")
public func gpioSet(pin: Int32, high: CBool) {
    let mask: UInt32 = 1 << pin
    let sioBasePtr = UnsafeMutableRawPointer(bitPattern: SIO_BASE)!
    if high {
        // Volatile memory access, not actually safe in Swift
        sioBasePtr.storeBytes(of: mask, toByteOffset: SIO_GPIO_OUT_SET_OFFSET, as: UInt32.self)
    } else {
        // Volatile memory access, not actually safe in Swift
        sioBasePtr.storeBytes(of: mask, toByteOffset: SIO_GPIO_OUT_CLR_OFFSET, as: UInt32.self)
    }
}

