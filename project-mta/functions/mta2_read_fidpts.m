function fidpts = x_read_fidpts(subj)
%% read fiducial points into the mta_coreg function

%% fiducial points

fidpts                  = [];

switch subj
%     
    case 's1'
        fidpts.nas      = [ 98 193 139];
        fidpts.lpa      = [ 19  98  93];
        fidpts.rpa      = [181  98  95];
        fidpts.zpoint   = [ 98  91 198];
    case 's2' 
        fidpts.nas      = [131 249  99];
        fidpts.lpa      = [ 53 163  67];
        fidpts.rpa      = [208 160  69];
        fidpts.zpoint   = [131 146 171];
    case 's3' 
        fidpts.nas      = [133 241 105];
        fidpts.lpa      = [ 48 152  66];
        fidpts.rpa      = [208 135  71];
        fidpts.zpoint   = [133 151 174]; 
    case 's5'
        fidpts.nas      = [129 240 101];
        fidpts.lpa      = [ 51 139  78];
        fidpts.rpa      = [205 140  76];
        fidpts.zpoint   = [157 139 177]; 
    case 's6'
        fidpts.nas      = [131 203  99];
        fidpts.lpa      = [ 56 109  63];
        fidpts.rpa      = [202 110  75];
        fidpts.zpoint	= [143 108 174];
    case 's8'
        fidpts.nas      = [130 227  91];
        fidpts.lpa      = [ 55 127  79];
        fidpts.rpa      = [205 130  76];
        fidpts.zpoint   = [130 130 194];
    case 's9' 
        fidpts.nas      = [134 218  79];
        fidpts.lpa      = [ 54 123  68];
        fidpts.rpa      = [199 115  59];
        fidpts.zpoint   = [134 108 174];
    case 's11'
        fidpts.nas      = [122 243 108];
        fidpts.lpa      = [ 53 138  85];
        fidpts.rpa      = [198 146  90];
        fidpts.zpoint   = [122 165 189];
    case 's12'
        fidpts.nas      = [127 223  94];
        fidpts.lpa      = [ 56 126  75];
        fidpts.rpa      = [198 131  75];
        fidpts.zpoint   = [127 129 188];
    case 's13'
        fidpts.nas      = [100 222 100];
        fidpts.lpa      = [ 27 119  86];
        fidpts.rpa      = [167 116  82];
        fidpts.zpoint   = [100 124 190];
    case 's14' 
        fidpts.nas      = [135 216 106];
        fidpts.lpa      = [ 53 125  63];
        fidpts.rpa      = [205 122  64];
        fidpts.zpoint   = [135 104 177];
    case 's16'
        fidpts.nas      = [103 213 118];
        fidpts.lpa      = [ 29 116  82];
        fidpts.rpa      = [172 112  80];
        fidpts.zpoint   = [103 110 199];
    case 's17'
        fidpts.nas      = [124 205  98];
        fidpts.lpa      = [ 52 105  84];
        fidpts.rpa      = [200 109  87];
        fidpts.zpoint   = [124 113 181];
    case 's18'
        fidpts.nas      = [121 210 100];
        fidpts.lpa      = [ 59 116  67];
        fidpts.rpa      = [200 126  66];
        fidpts.zpoint   = [121 119 165];
    case 's19'
        fidpts.nas      = [ 93 319  85];
        fidpts.lpa      = [ 15 224  57];
        fidpts.rpa      = [159 216  63];
        fidpts.zpoint   = [ 93 219 179];
    case 's21'
        fidpts.nas      = [130 216 105];
        fidpts.lpa      = [ 54 119  72];
        fidpts.rpa      = [201 113  76];
        fidpts.zpoint   = [130 101 186];
    case 's22'
        fidpts.nas      = [128 208 104];
        fidpts.lpa      = [ 55 121  78];
        fidpts.rpa      = [192 117  76];
        fidpts.zpoint   = [128 110 180];
    case 's24'
        fidpts.nas      = [136 222  92];
        fidpts.lpa      = [ 59 125  89];
        fidpts.rpa      = [203 116  87];
        fidpts.zpoint   = [136 113 187];
    case 's25'
        fidpts.nas      = [139 220 103];
        fidpts.lpa      = [ 63 126  71];
        fidpts.rpa      = [206 119  69];
        fidpts.zpoint   = [139 117 171];
    case 's26'
        fidpts.nas      = [129 228  86];
        fidpts.lpa      = [ 61 129  78];
        fidpts.rpa      = [197 131  78];
        fidpts.zpoint   = [129 128 180];
    case 's27'
        fidpts.nas      = [122 254  94];
        fidpts.lpa      = [ 53 157  69];
        fidpts.rpa      = [203 164  69];
        fidpts.zpoint   = [122 145 191];
    case 's28'
        fidpts.nas      = [131 243 107];
        fidpts.lpa      = [ 61 152  82];
        fidpts.rpa      = [198 147  85];
        fidpts.zpoint   = [131 158 186];
    case 's29'
        fidpts.nas      = [ 98 218 126];
        fidpts.lpa      = [ 22 123  85];
        fidpts.rpa      = [173 127  79];
        fidpts.zpoint   = [ 98 122 194];
    case 's30'
        fidpts.nas      = [124 229  94];
        fidpts.lpa      = [ 56 135  74];
        fidpts.rpa      = [198 139  79];
        fidpts.zpoint   = [124 128 179];
    case 's31'
        fidpts.nas      = [126 212 112];
        fidpts.lpa      = [ 53 125  60];
        fidpts.rpa      = [202 129  55];
        fidpts.zpoint   = [126 121 177];
    case 's32'
        fidpts.nas      = [125 243 134];
        fidpts.lpa      = [ 56 149  85];
        fidpts.rpa      = [201 151  87];
        fidpts.zpoint   = [125 149 187];
    case 's33'
        fidpts.nas      = [127 230 101];
        fidpts.lpa      = [ 61 131  88];
        fidpts.rpa      = [199 139  89];
        fidpts.zpoint   = [127 138 184];
    case 's34'
        fidpts.nas      = [113 214  96];
        fidpts.lpa      = [ 48 115  78];
        fidpts.rpa      = [187 126  83];
        fidpts.zpoint   = [113 118 193];
    case 's35'
        fidpts.nas      = [129 215  85];
        fidpts.lpa      = [ 49 109  55];
        fidpts.rpa      = [203 109  49];
        fidpts.zpoint   = [129 115 155];
   
        
end


























