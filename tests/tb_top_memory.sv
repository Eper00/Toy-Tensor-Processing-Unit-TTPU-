module tb_top_memory;

    parameter DATA_WIDTH = 16;
    parameter IMAGE_WIDTH = 4;
    parameter IMAGE_HEIGHT = 4;
    parameter NUM_UNITS = 2;
    parameter MEM_DEPTH = IMAGE_WIDTH * IMAGE_HEIGHT;

    logic clk, reset, step, en;

    logic read_mem1, write_mem1;
    logic read_mem2, write_mem2;

    logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim;

    logic [NUM_UNITS-1:0][$clog2(MEM_DEPTH)-1:0] start_addr_1;
    logic [NUM_UNITS-1:0][$clog2(MEM_DEPTH)-1:0] start_addr_2;

    logic [NUM_UNITS-1:0][$clog2(MEM_DEPTH)-1:0] simple_addr;
    logic simple_write;
    logic simple_read;

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_1, out_2, simple_mem_out;

    // DUT
    top_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .step(step),
        .en(en),
        .read_mem1(read_mem1),
        .write_mem1(write_mem1),
        .read_mem2(read_mem2),
        .write_mem2(write_mem2),
        .data_in(data_in),
        .start_addr_1(start_addr_1),
        .start_addr_2(start_addr_2),
        .kernel_dim(kernel_dim),
        .simple_addr(simple_addr),
        .simple_write(simple_write),
        .simple_read(simple_read),
        .out_1(out_1),
        .out_2(out_2),
        .simple_mem_out(simple_mem_out)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        integer i;
        $display("---- top_memory sequential write-read test ----");

        // Init
        clk = 0;
        reset = 1;
        en = 0;
        step = 0;
        read_mem1 = 0;
        write_mem1 = 0;
        read_mem2 = 0;
        write_mem2 = 0;
        simple_write = 0;
        kernel_dim = 2;
        simple_read = 0;
        #10 reset = 0;
        en = 1;

        // ---- Write to mem1 ----
        $display("Writing to mem1...");
        for (i = 0; i < MEM_DEPTH; i++) begin
            data_in = '{i + 1, i + 100};
            start_addr_1 = '{i, i};
            write_mem1 = 1;
            #10;
            write_mem1 = 0;
            #10;
        end

        // ---- Write to mem2 ----
        $display("Writing to mem2...");
        for (i = 0; i < MEM_DEPTH; i++) begin
            data_in = '{i + 200, i + 300};
            start_addr_2 = '{i, i};
            write_mem2 = 1;
            #10;
            write_mem2 = 0;
            #10;
        end

        // ---- Write to simple memory ----
        $display("Writing to simple memory...");
        for (i = 0; i < MEM_DEPTH; i++) begin
            data_in = '{i + 400, i + 500};
            simple_write_addr = '{i, i};
            simple_write = 1;
            #10;
            simple_write = 0;
            #10;
        end

        // ---- Read from mem1 and mem2 ----
        $display("Reading from memories using step...");
        read_mem1 = 1;
        read_mem2 = 1;
        simple_read = 1;
        start_addr_1 = '{0, 0};
        start_addr_2 = '{0, 0};
        #10;

        for (i = 0; i < MEM_DEPTH; i++) begin
            step = 1;
            #10 step = 0;
            #10;
            $display("Step %0d | out_1: %0h %0h | out_2: %0h %0h", i, out_1[0], out_1[1], out_2[0], out_2[1]);
        end

        // ---- Read back simple memory ----
        $display("Reading back simple memory...");
        for (i = 0; i < MEM_DEPTH; i++) begin
            simple_write_addr = '{i, i};  // reuse address bus for read
            #10;
            $display("Addr %0d | simple_mem_out: %0h %0h", i, simple_mem_out[0], simple_mem_out[1]);
        end

        $finish;
    end

endmodule
