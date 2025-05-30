module tb_tensor_processing_unit;

    parameter DATA_WIDTH = 16;
    parameter IMAGE_WIDTH = 5;
    parameter IMAGE_HEIGHT = 5;
    parameter NUM_UNITS = 9;
    parameter MEM_SIZE = IMAGE_WIDTH * IMAGE_HEIGHT;

    logic clk, reset, en;
    logic read_mem1, write_mem1, read_mem2, write_mem2;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in;
    logic [NUM_UNITS-1:0][$clog2(MEM_SIZE)-1:0] start_addr_1, start_addr_2;
    logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim;
    logic [NUM_UNITS-1:0][$clog2(MEM_SIZE)-1:0] simple_addr;
    logic simple_write, simple_read;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_1, out_2, simple_mem_out;
    logic start;
    logic [NUM_UNITS-1:0] active_units;
    logic [($clog2(IMAGE_WIDTH)-1)*($clog2(IMAGE_WIDTH)-1):0] length;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] relu_out;
    logic done;
    logic en_1;
    logic en_2;
    // Instantiate TPU
    tensor_processing_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
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
        .start(start),
        .active_units(active_units),
        .length(length),
        .relu_out(relu_out),
        .done(done),
        .mem_en1(en_1),
        .mem_en2(en_2)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Memory data
    logic [15:0] mem1_data_1_1 [0:24] = '{
        16'h0000, 16'h0000, 16'h3C00, 16'h3C00, 16'h0000,
        16'h0000, 16'h3C00, 16'h0000, 16'h3C00, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h3C00, 16'h0000,
        16'h0000, 16'h0000, 16'h3C00, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h3C00, 16'h0000
    };
 // 0 0 1 1 0
 // 0 1 0 1 0
 // 0 0 0 1 0 
 // 0 0 1 0 0
 // 0 0 0 1 0
     logic [15:0] mem1_data_1_2 [0:24] = '{
        16'h0000, 16'h3C00, 16'h0000, 16'h0000, 16'h0000,
        16'h3C00, 16'h3C00, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h3C00, 16'h0000, 16'h0000,
        16'h0000, 16'h3C00, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h3C00, 16'h0000, 16'h0000, 16'h0000
    };
 // 0 1 0 0 0
 // 1 1 0 0 0
 // 0 0 1 0 0 
 // 0 1 0 0 0
 // 0 1 0 0 0
      logic [15:0] mem1_data_1_3 [0:24] = '{
        16'h0000, 16'h0000, 16'h3C00, 16'h0000, 16'h0000,
        16'h0000, 16'h3C00, 16'h3C00, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h3C00, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h3C00, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h3C00, 16'h0000, 16'h0000
    };
 // 0 0 1 0 0
 // 0 1 1 0 0
 // 0 0 1 0 0 
 // 0 0 1 0 0
 // 0 0 1 0 0
 
 
 
 
 
    logic [15:0] mem1_data_0_1 [0:24] = '{
        16'h0000, 16'h3C00, 16'h0000, 16'h0000, 16'h0000,
        16'h3C00, 16'h0000, 16'h3C00, 16'h0000, 16'h0000,
        16'h3C00, 16'h0000, 16'h0000, 16'h3C00, 16'h0000,
        16'h3C00, 16'h0000, 16'h0000, 16'h3C00, 16'h0000,
        16'h0000, 16'h3C00, 16'h3C00, 16'h0000, 16'h0000
    };

 // 0 1 0 0 0
 // 1 0 1 0 0
 // 1 0 0 1 0 
 // 1 0 0 1 0
 // 0 1 1 0 0

    logic [15:0] mem1_data_0_2 [0:24] = '{
        16'h0000, 16'h3C00, 16'h3C00, 16'h0000, 16'h0000,
        16'h3C00, 16'h0000, 16'h0000, 16'h3C00, 16'h0000,
        16'h3C00, 16'h0000, 16'h0000, 16'h3C00, 16'h0000,
        16'h3C00, 16'h0000, 16'h0000, 16'h3C00, 16'h0000,
        16'h0000, 16'h3C00, 16'h3C00, 16'h0000, 16'h0000
    };

 // 0 1 1 0 0
 // 1 0 0 1 0
 // 1 0 0 1 0 
 // 1 0 0 1 0
 // 0 1 1 0 0

    logic [15:0] mem1_data_0_3 [0:24] = '{
        16'h0000, 16'h3C00, 16'h3C00, 16'h3C00, 16'h0000,
        16'h0000, 16'h3C00, 16'h0000, 16'h3C00, 16'h0000,
        16'h3C00, 16'h0000, 16'h0000, 16'h3C00, 16'h0000,
        16'h3C00, 16'h3C00, 16'h0000, 16'h3C00, 16'h0000,
        16'h0000, 16'h0000, 16'h3C00, 16'h3C00, 16'h0000
    };

 // 0 1 1 1 0
 // 1 0 0 1 0
 // 1 0 0 1 0 
 // 1 1 0 1 0
 // 0 0 1 1 0


    logic [15:0] mem2_data [0:24] = '{
        16'h3C00, 16'h0000, 16'hBC00, 16'h0000, 16'h0000,
        16'h3C00, 16'h0000, 16'hBC00, 16'h0000, 16'h0000,
        16'h3C00, 16'h0000, 16'hBC00, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000
    };
// 1 0 -1 0 0
// 1 0 -1 0 0
// 1 0 -1 0 0
// 0 0  0 0 0 
// 0 0  0 0 0








// RESULT= mem_1(1)1 x mem_2
// 0 0 1
// 0 0 1
// 0 0 1
// RESULT= mem_1(2)1 x mem_2
// 0 2 1
// 0 2 1
// 0 2 1


// RESULT= mem_1(3)1 x mem_2
// 0 1 3
// 0 1 3
// 0 0 3


// RESULT= mem_1(1)0 x mem_2
// 1 0 1
// 2 0 1
// 1 0 1

// RESULT= mem_1(2)0 x mem_2
// 1 0 1
// 3 0 0
// 1 0 1

// RESULT= mem_1(3)0 x mem_2
// 0 0 1
// 1 0 0
// 1 0 1



    logic [15:0] simple_mem_data [0:24] = '{
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000
     };
    // Write routine
task write_memory;
    integer i, j;

    // 1. Memória 1 feltöltése
    for (i = 0; i < MEM_SIZE; i += NUM_UNITS) begin
        @(posedge clk);
        write_mem1 <= 1;
        write_mem2 <= 0;
        simple_write <= 0;

        for (j = 0; j < NUM_UNITS; j++) begin
            if (i + j < MEM_SIZE) begin
                data_in[j] <= mem1_data_0_3[i + j];
                start_addr_1[j] <= i + j;
            end else begin
                data_in[j] <= '0;
                start_addr_1[j] <= i+j;
            end
        end
    end

    // Deaktiválás
    @(posedge clk);
    write_mem1 <= 0;

    // 2. Memória 2 feltöltése
    for (i = 0; i < MEM_SIZE; i += NUM_UNITS) begin
        @(posedge clk);
        write_mem1 <= 0;
        write_mem2 <= 1;
        simple_write <= 0;

        for (j = 0; j < NUM_UNITS; j++) begin
            if (i + j < MEM_SIZE) begin
                data_in[j] <= mem2_data[i + j];
                start_addr_2[j] <= i + j;
            end else begin
                data_in[j] <= '0;
                start_addr_2[j] <= i+j;
            end
        end
    end

    // Deaktiválás
    @(posedge clk);
    write_mem2 <= 0;

    // 3. Simple memória feltöltése
    for (i = 0; i < MEM_SIZE; i += NUM_UNITS) begin
        @(posedge clk);
        write_mem1 <= 0;
        write_mem2 <= 0;
        simple_write <= 1;

        for (j = 0; j < NUM_UNITS; j++) begin
            if (i + j < MEM_SIZE) begin
                data_in[j] <= simple_mem_data[i + j];
                simple_addr[j] <= i + j;
            end else begin
                data_in[j] <= '0;
                simple_addr[j] <= '0;
            end
        end
    end

    // Deaktiválás
    @(posedge clk);
    simple_write <= 0;

endtask


    // Initial block
    initial begin
        clk = 0;
        reset = 1;
        en = 1;
        write_mem1 = 0;
        write_mem2 = 0;
        read_mem1 = 0;
        read_mem2 = 0;
        simple_write = 0;
        simple_read = 0;
        start = 0;
        kernel_dim = 3;
        active_units = 9'b111111111;
        length = 9; // 3x3 kernel
  
        #10
        reset <= 0;
        
       
        
        // Memóriák írása
        write_memory(); // írjuk mem1-be
        #10;
        write_mem1<=0;
        write_mem2<=0;
        simple_write<=0;
        
        start_addr_1[0]<=18'h0000;
        start_addr_1[1]<=18'h0001;
        start_addr_1[2]<=18'h0002;
        
        start_addr_1[3]<=18'h0005;
        start_addr_1[4]<=18'h0006;
        start_addr_1[5]<=18'h0007;
        
        start_addr_1[6]<=18'h000A;
        start_addr_1[7]<=18'h000B;
        start_addr_1[8]<=18'h000C;
        for (integer i=0;i<NUM_UNITS;i=i+1)begin
            start_addr_2[i]<=0;
            simple_addr[i]<=0;
        end
        #10
        read_mem1<=1;
        read_mem2<=1;
        simple_read<=1;
        #10
        start<=1;
        wait(done);
        
        
    end

endmodule
