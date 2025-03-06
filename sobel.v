module SOBEL_FILTER (
    input [7:0] S00, S01, S02,
    input [7:0] S10, S11, S12,
    input [7:0] S20, S21, S22,
    input CK,
    input RES,
    output reg [7:0] D
);
    reg signed [10:0] GX, GY;
    reg signed [11:0] G;  
//ソーベルフィルタブロック
    always @(posedge CK or posedge RES) begin
        if (RES) begin
            D <= 8'b0;
        end else begin
            GX = (-1 * S00) + ( 0 * S01) + ( 1 * S02) 
               + (-2 * S10) + ( 0 * S11) + ( 2 * S12) 
               + (-1 * S20) + ( 0 * S21) + ( 1 * S22);  //水平方向

            GY = (-1 * S00) + (-2 * S01) + (-1 * S02) 
               + ( 0 * S10) + ( 0 * S11) + ( 0 * S12) 
               + ( 1 * S20) + ( 2 * S21) + ( 1 * S22);  //垂直方向

//エッジ強度計算
            G = (GX < 0 ? -GX : GX) + (GY < 0 ? -GY : GY); 

//スケーリングの調整
            G = G >> 2;  

            if (G > 25)  //閾値
                D <= 8'hFF;  //エッジ部分白
            else
                D <= 8'h00;
        end
    end
endmodule





