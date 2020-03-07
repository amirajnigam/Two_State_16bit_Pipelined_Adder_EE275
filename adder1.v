//////////////////////////////////////////////////////////////////////////
//****************************************
//Pipelined Adder in Verilog
//****************************************


module add_1p (x, y, sum, clk);

parameter WIDTH  = 16,  // Total bit width
          LSB_WIDTH = 8,   // Bit width of LSBs
          MSB_WIDTH = 8;   // Bit width of MSBs

input [WIDTH-1:0] x,y; // Inputs
output [WIDTH-1:0] sum; // Result 
input clk; // Clock

reg [LSB_WIDTH-1:0] l1, l2; // LSBs of inputs 
wire [LSB_WIDTH-1:0] q1, r1; /// LSBs of inputs 
reg [MSB_WIDTH-1:0] l3, l4; // MSBs of input 
wire [MSB_WIDTH-1:0] r2, q2, u2; // MSBs of input 
wire cr1,cq1; // LSBs carry signal

wire [MSB_WIDTH-1:0] h2; // Auxiliary MSBs of input 

// Split in MSBs and LSBS and store in registers
always @(posedge clk) begin
// Split LSBs from input x,y 
//l1[LSB_WIDTH-1:0] <= x[LSB_WIDTH-1:0];
//l2[LSB_WIDTH-1:0] <= y[LSB_WIDTH-1:0];
// Split MSBs from input x,y
l3[MSB_WIDTH-1:0] <= x[MSB_WIDTH-1+LSB_WIDTH:LSB_WIDTH];
l4[MSB_WIDTH-1:0] <= y[MSB_WIDTH-1+LSB_WIDTH:LSB_WIDTH];
end

/************* First stage of the adder *****************/
lpm_add_sub #(LSB_WIDTH, "ADD") add_1 // Add LSBs of x and y
(.result(r1), .dataa(x[LSB_WIDTH-1:0]), .datab(y[LSB_WIDTH-1:0]), .cin(1'b0), .cout(cr1)); // Used ports

lpm_ff #(LSB_WIDTH) reg_1 // Save LSBs of x+y
(.data(r1), .q(q1), .clock(clk));

lpm_ff #(1) reg_2 // Save LSBs carry
(.data(cr1), .q(cq1), .clock(clk));

lpm_add_sub #(MSB_WIDTH, "ADD") add_2 //Add MSBs of x and y
(.dataa(l3), .datab(l4),.result(r2), .cin(cq1), .cout()); //Used ports

//lpm_ff #(MSB_WIDTH) reg_3 // Save MSBs of x+y
//(.data(r2), .q(q2), .clock(clk)); // Used ports

assign sum = {r2,q1};

endmodule

module lpm_ff #(parameter WIDTH = 1)
(input [WIDTH-1:0] data, output reg [WIDTH-1:0] q, input clock);
always @(posedge clock) begin
   q <= data;
end
endmodule

module lpm_add_sub #(parameter WIDTH = 1, parameter ALU = "ADD")
(input [WIDTH-1:0] dataa, input [WIDTH-1:0] datab, input cin, output cout, output [WIDTH-1:0] result);

reg [WIDTH:0] temp;

always @* begin
case(ALU)
   "ADD" : temp = dataa + datab + cin;
   "SUB" : temp = dataa - datab;
   default: temp = {WIDTH{1'b1}};
endcase
end
assign cout = temp[WIDTH];
assign result = temp[WIDTH-1:0];

//assign {cout,result} = dataa + datab + cin;
endmodule
