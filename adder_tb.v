module adder_tb();

parameter WIDTH = 16,
          LSB_WIDTH = 8,
          MSB_WIDTH = 8;

reg  clk;
reg  [WIDTH-1:0] x,y;
wire [WIDTH-1:0] sum;

reg  [WIDTH-1:0] x_r, y_r;

add_1p #(WIDTH, LSB_WIDTH, MSB_WIDTH) u_adder_1p
(x, y, sum, clk);

initial begin
   clk=0;
   forever #5 clk=~clk;
end

initial begin
   x=0;
   y=0;
   repeat(20) begin
      @(posedge clk);
      #1;
      x=$random;
      y=$random;
   end
   #20;
   $finish;
end

always @(posedge clk) begin
   x_r <= x;
   y_r <= y;
end

always @(posedge clk) begin
   if(sum === x_r + y_r)
      $display("Adder PASSED: A = %h :: B = %h :: SUM = %h",x_r, y_r, sum);
   else
      $display("Adder FAILED: A = %h :: B = %h :: SUM = %h",x_r, y_r, sum);
end

initial begin
   $dumpfile("adder.vcd");
   $dumpvars(0);
end

endmodule
