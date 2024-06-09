module tt_um_salomon9920_top (
    input  wire clk,
    input  wire reset,
    output tri  scl,
    inout  tri  sda,
    output reg  tx
);
    // Se�ales internas
    logic cs, read, write;
    logic [4:0] addr;
    logic [31:0] wr_data;
    logic [31:0] rd_data;
    logic [31:0] sensor_data;

    // Instancia del I2C core
    chu_i2c_core i2c_core_inst (
        .clk(clk),
        .reset(reset),
        .cs(cs),
        .read(read),
        .write(write),
        .addr(addr),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .scl(scl),
        .sda(sda)
    );

    // Instancia del UART
    uart_tx uart_tx_inst (
        .clk(clk),
        .reset(reset),
        .sensor_data(sensor_data),
        .tx(tx)
    );

    // Direcci�n del dispositivo I2C (LM75)
    localparam [6:0] LM75_ADDR = 7'b1001000; // Direcci�n I2C del LM75

    // Estados para la m�quina de estados
    typedef enum logic [1:0] {
        IDLE,
        READ_TEMP
    } state_t;

    state_t state, next_state;

    // M�quina de estados para la lectura del registro de temperatura
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            cs <= 0;
            read <= 0;
            write <= 0;
            addr <= 0;
            wr_data <= 0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    // Configuraci�n para leer el registro de temperatura
                    cs <= 1;
                    read <= 1;
                    write <= 0;
                    addr <= 5'b00010; // Direcci�n del registro de temperatura del LM75
                    wr_data <= {24'b0, LM75_ADDR, 1'b1}; // Direcci�n del dispositivo + bit de lectura
                    next_state <= READ_TEMP;
                end
                READ_TEMP: begin
                    cs <= 0;
                    read <= 0;
                    next_state <= IDLE;
                end
            endcase
        end
    end

    // Asignaci�n de los datos le�dos
    assign sensor_data = rd_data;
endmodule
