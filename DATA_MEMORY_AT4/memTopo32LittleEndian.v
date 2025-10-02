module memTopo32LittleEndian #(
    parameter DATA_WIDTH   = 32,
    parameter ADDRESS_WIDTH = 4
) (
    input wire clk,                           //! Clock
    input wire [1:0] size,                    //! funct3[1:0] 00: byte, 01: half, 10: word
    input wire [ADDRESS_WIDTH-1:0] addr,      //! Endereco
    input wire [DATA_WIDTH-1:0] din,          //! Entrada de dados
    input wire sign_ext,                      //! funct3[2] 0: extensão de sinal, 1: zero extension
    input wire writeEnable,                   //! Habilita escrita (vem do controle)
  output wire [DATA_WIDTH-1:0] dout         //! Saida de dados
);

    wire [3:0]  byteEnable;
    wire [31:0] mem_dout;
    wire [31:0] rdata;

    // Decodificador de byte enable
    byteEnableDecoder decoder (
        .addr_offset(addr[1:0]),
        .size(size),
        .byteEnable(byteEnable),
        .writeEnable(writeEnable)
    );

    // Memória endereçável por byte (write-first)
    memByteAddressable32WF mem_inst (
        .clk(clk),
        .byteEnable(byteEnable),
      .addr(addr[5:2]),   // endereçamento por palavra (alinhado)
        .din(din),
        .dout(mem_dout)
    );

    // Gerenciador de leitura com extensão de sinal/zero
    memReadManager read_inst (
        .dout(mem_dout),
        .addr_offset(addr[1:0]),
        .size(size),
        .sign_extend(sign_ext),
        .rdata(rdata)
    );

    assign dout = rdata;

endmodule

module byteEnableDecoder (
    input wire [1:0] addr_offset,     //! addr[1:0] - memória alinhada
    input wire [1:0] size,            //! funct3[1:0] - 00: byte, 01: half, 10: word
    output reg [3:0] byteEnable,      //! Saída em One Hot para memória
    input wire writeEnable            //! Habilita escrita (vem do controle)
);
    always @(*) begin
        if (!writeEnable) begin
            byteEnable = 4'b0000;
        end else begin
            case (size)
                2'b00: byteEnable = 4'b0001 << addr_offset; //SB
                2'b01: begin // SH - Store Half-word
                    case (addr_offset)
                        2'b00: byteEnable = 4'b0011;
                        2'b01: byteEnable = 4'b0110;
                        2'b10: byteEnable = 4'b1100;
                        default: byteEnable = 4'b0000; // desalinhado
                    endcase
                end
                2'b10: byteEnable = 4'b1111; //SW
                default: byteEnable = 4'b0000;
            endcase
        end
    end
endmodule



// Funcionalidade: Memória byte-addressable de 32 bits com escrita por byte habilitada

module memByteAddressable32WF #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 4
)(
    input wire clk,
    input wire [3:0] byteEnable,
    input wire [ADDRESS_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] din,
    output wire [DATA_WIDTH-1:0] dout
);

    // Byte 0 - LSB (din[7:0]), habilitado por byteEnable[0]
    memory_write_first #(
        .DATA_WIDTH(8),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) mem_byte0 (
        .clk(clk),
        .we(byteEnable[0]),
        .addr(addr),
        .din(din[7:0]),
        .dout(dout[7:0])
    );

    // Byte 1 (din[15:8]), habilitado por byteEnable[1]
    memory_write_first #(
        .DATA_WIDTH(8),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) mem_byte1 (
        .clk(clk),
        .we(byteEnable[1]),
        .addr(addr),
        .din(din[15:8]),
        .dout(dout[15:8])
    );

    // Byte 2 (din[23:16]), habilitado por byteEnable[2]
    memory_write_first #(
        .DATA_WIDTH(8),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) mem_byte2 (
        .clk(clk),
        .we(byteEnable[2]),
        .addr(addr),
        .din(din[23:16]),
        .dout(dout[23:16])
    );

    // Byte 3 - MSB (din[31:24]), habilitado por byteEnable[3]
    memory_write_first #(
        .DATA_WIDTH(8),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) mem_byte3 (
        .clk(clk),
        .we(byteEnable[3]),
        .addr(addr),
        .din(din[31:24]),
        .dout(dout[31:24])
    );

endmodule

// Módulo: memory_write_first
// Funcionalidade: Escrita síncrona com leitura assíncrona

module memory_write_first #(
    parameter DATA_WIDTH = 8,
    parameter ADDRESS_WIDTH = 4
)(
    input wire clk,
    input wire we,
    input wire [ADDRESS_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

    // Define profundidade da memória
    localparam DEPTH = 1 << ADDRESS_WIDTH;

    // Declaração da memória
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Escrita síncrona com prioridade
    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;
    end

    // Leitura assíncrona
    always @(*) begin
        dout = mem[addr];
    end

endmodule

module memReadManager (
    input wire [31:0] dout,           //! Palavra lida da memória (sempre 32 bits)
    input wire [1:0] addr_offset,     //! addr[1:0] (offset do byte)
    input wire [1:0] size,            //! 00: byte, 01: half-word, 10: word
    input wire sign_extend,           //! 0: extensão de sinal, 1: zero extension
    output reg [31:0] rdata           //! Dado lido final, com extensão adequada
);
    reg [7:0] byte_data;
    reg [15:0] halfword_data;

    always @(*) begin
        case (addr_offset)
            2'b00: begin
                byte_data     = dout[7:0];
                halfword_data = dout[15:0];
            end
            2'b01: begin
                byte_data     = dout[15:8];
                halfword_data = dout[23:8];
            end
            2'b10: begin
                byte_data     = dout[23:16];
                halfword_data = dout[31:16];
            end
            2'b11: begin
                byte_data     = dout[31:24];
                halfword_data = {8'b0, dout[31:24]}; // inválido p/ halfword
            end
            default: begin
                byte_data     = 8'b0;
                halfword_data = 16'b0;
            end
        endcase

        case (size)
            2'b00: begin // byte
                rdata = ~sign_extend ?
                        {{24{byte_data[7]}}, byte_data} :
                        {24'b0, byte_data};
            end
            2'b01: begin // half-word
                rdata = ~sign_extend ?
                        {{16{halfword_data[15]}}, halfword_data} :
                        {16'b0, halfword_data};
            end
            2'b10: begin // word
                rdata = dout;
            end
            default: begin // valor padrão para debug "DEAD BEEF"
                rdata = 32'hDEADBEEF; // erro leitura inválida
            end
        endcase
    end
endmodule
