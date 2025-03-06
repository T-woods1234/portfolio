`timescale 1ns / 1ps

module SOBEL_TB;
    localparam IMG_H = 854;  //幅
    localparam IMG_W = 1280;  //高さ
    localparam HEADER_SIZE = 14;  //ヘッダーサイズ
    localparam INFO_SIZE = 40;  //infoサイズ
    localparam PALETTE_SIZE = 1024;  //パレットサイズ
    localparam BYTES = 1; //ビット数(8bit)
    
    reg [7:0] image [0:IMG_H*IMG_W-1];  //入力画素データ
    reg [7:0] output_image [0:IMG_H*IMG_W-1];  //処理後の画素データ
    reg [7:0] header [0:HEADER_SIZE-1];  //ヘッダー
    reg [7:0] info [0:INFO_SIZE-1];  //info
    reg [7:0] palette [0:PALETTE_SIZE-1]; //パレット
    reg [7:0] pixel_data [0:IMG_H*IMG_W*BYTES-1];
    reg [7:0] S00, S01, S02;
    reg [7:0] S10, S11, S12;
    reg [7:0] S20, S21, S22;  //ソーベルフィルタの3×3のブロック
    reg CK;
    reg RES;
    wire [7:0] D;  //出力

    SOBEL_FILTER uut (
        .S00(S00), .S01(S01), .S02(S02),
        .S10(S10), .S11(S11), .S12(S12),
        .S20(S20), .S21(S21), .S22(S22),
        .CK(CK),
        .RES(RES),
        .D(D)
    );

    integer f, i, j, index;
//ファイル読み込み
    initial begin
        f = $fopen("rowing.bmp", "rb");
        
        for (i = 0; i < HEADER_SIZE; i = i + 1)
            header[i] = $fgetc(f);
        
        for (i = 0; i < INFO_SIZE; i = i + 1)
            info[i] = $fgetc(f);
        
        for (i = 0; i < PALETTE_SIZE; i = i + 1)
            palette[i] = $fgetc(f); 
        
        for (i = 0; i < IMG_H * IMG_W; i = i + 1)
            image[i] = $fgetc(f); 
        
        $fclose(f);
//ソーベルフィルタ処理
        CK = 0;
        RES = 1;
        #10 RES = 0;

        for (i = 1; i < IMG_H - 1; i = i + 1) begin
            for (j = 1; j < IMG_W - 1; j = j + 1) begin
                index = i * IMG_W + j;
                
                S00 = image[index - IMG_W - 1]; S01 = image[index - IMG_W]; S02 = image[index - IMG_W + 1];
                S10 = image[index - 1]; S11 = image[index]; S12 = image[index + 1];
                S20 = image[index + IMG_W - 1]; S21 = image[index + IMG_W]; S22 = image[index + IMG_W + 1];

                #10;
                output_image[index] = D;
                #10;
            end
        end
//ファイル出力
        f = $fopen("result.bmp", "wb");

        for (i = 0; i < HEADER_SIZE; i = i + 1)
            $fwrite(f, "%c", header[i]);
        for (i = 0; i < INFO_SIZE; i = i + 1)
            $fwrite(f, "%c", info[i]);
        for (i = 0; i < PALETTE_SIZE; i = i + 1)
            $fwrite(f, "%c", palette[i]); 

        for (i = 0; i < IMG_H; i = i + 1) begin
            for (j = 0; j < IMG_W; j = j + 1) begin
                $fwrite(f, "%c", output_image[i * IMG_W + j]);  //処理後の画素データ
            end
        end
        
        $fclose(f);
        $stop;
    end

    initial begin
        $dumpfile("sobel_wave.vcd");
        $dumpvars(0, SOBEL_TB);
    end

    always #5 CK = ~CK;
    
endmodule







