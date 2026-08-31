cols = [540, 700, 1800, 1500, 1120, 3700]
HDR_FILL  = "1F4E79"
ODD_FILL  = "EBF3FB"
EVN_FILL  = "FFFFFF"
FONT      = "Trebuchet MS"
BRD_COLOR = "BFBFBF"

def border():
    b = f'w:val="single" w:sz="1" w:space="0" w:color="{BRD_COLOR}"'
    return f'<w:top {b}/><w:left {b}/><w:bottom {b}/><w:right {b}/>'

def cell(text, width, fill, bold=False, white=False, center=False, sz=18):
    jc = '<w:jc w:val="center"/>' if center else '<w:jc w:val="left"/>'
    color = '<w:color w:val="FFFFFF"/>' if white else '<w:color w:val="000000"/>'
    b = '<w:b/><w:bCs/>' if bold else ''
    return f"""        <w:tc>
          <w:tcPr>
            <w:tcW w:w="{width}" w:type="dxa"/>
            <w:tcBorders>{border()}</w:tcBorders>
            <w:shd w:val="clear" w:color="auto" w:fill="{fill}"/>
            <w:tcMar>
              <w:top w:w="80" w:type="dxa"/>
              <w:left w:w="120" w:type="dxa"/>
              <w:bottom w:w="80" w:type="dxa"/>
              <w:right w:w="120" w:type="dxa"/>
            </w:tcMar>
            <w:vAlign w:val="center"/>
          </w:tcPr>
          <w:p>
            <w:pPr>
              {jc}
              <w:rPr><w:rFonts w:ascii="{FONT}" w:hAnsi="{FONT}"/></w:rPr>
            </w:pPr>
            <w:r>
              <w:rPr>
                <w:rFonts w:ascii="{FONT}" w:hAnsi="{FONT}"/>
                {b}{color}
                <w:sz w:val="{sz}"/><w:szCs w:val="{sz}"/>
              </w:rPr>
              <w:t xml:space="preserve">{text}</w:t>
            </w:r>
          </w:p>
        </w:tc>"""

def row(cells_data, fill, header=False):
    hdr_attr = '<w:tblHeader/>' if header else ''
    cells_xml = ''.join(cell(text, w, fill, bold=header, white=header, center=(i<=1), sz=18)
                        for i,(text,w) in enumerate(zip(cells_data, cols)))
    return f"""      <w:tr>
        <w:tblPrEx><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPrEx>
        <w:trPr>{hdr_attr}</w:trPr>
{cells_xml}
      </w:tr>"""

rows = [
    ("1","0x0000","addi $t0,$zero,5",  "$t0 &#x2190; 0 + 5",         "R[8] = 5",   "I-type ADDI: sign-extended imm=5 added to $zero; alusrc=1, regwrite=1, regdst=0"),
    ("2","0x0004","addi $t1,$zero,10", "$t1 &#x2190; 0 + 10",        "R[9] = 10",  "I-type ADDI: loads constant 10 into $t1; value visible on waveform bar immediately"),
    ("3","0x0008","add $t2,$t0,$t1",   "$t2 &#x2190; 5 + 10",        "R[10] = 15", "R-type ADD: ALUcontrol=010; regdst=1 (rd field used), alusrc=0 (register B)"),
    ("4","0x000C","sub $t3,$t1,$t0",   "$t3 &#x2190; 10 &#x2212; 5", "R[11] = 5",  "R-type SUB: ALUcontrol=110; two&#x2019;s complement subtraction (B inverted +1)"),
    ("5","0x0010","andi $t4,$t0,3",    "$t4 &#x2190; 5 &amp; 0x3",   "R[12] = 1",  "I-type ANDI: 0101&#x2082; AND 0011&#x2082; = 0001&#x2082; = 1; aluop=11&#x2192;ALUcontrol=000"),
    ("6","0x0014","sw $t2,0($zero)",   "Mem[0] &#x2190; $t2",        "Mem[0] = 15","SW: ALU computes addr=0+0=0; memwrite=1, writedata=15 stored to data memory"),
    ("7","0x0018","lw $s0,0($zero)",   "$s0 &#x2190; Mem[0]",        "R[16] = 15", "LW: addr=0, readdata=0x0F=15; memtoreg=1 routes memory output to register write-back"),
    ("8","0x001C","beq $t0,$t0,+1",    "if $t0==$t0 branch +1",      "PC = 0x0024","BEQ: ALU subtracts $t0&#x2212;$t0=0, zero=1, pcsrc=1; PC+12=0x24 (NOP at 0x20 skipped)"),
    ("9+","0x0024","nop (skipped)",    "no operation",               "&#x2014;",   "Post-branch NOP; register file and memory hold their final verified values"),
]

gridcols = "".join(f'<w:gridCol w:w="{c}"/>' for c in cols)
tbl = f"""    <w:tbl>
      <w:tblPr>
        <w:tblW w:w="9360" w:type="dxa"/>
        <w:tblBorders>
          <w:top w:val="single" w:sz="4" w:space="0" w:color="2E75B6"/>
          <w:left w:val="single" w:sz="4" w:space="0" w:color="2E75B6"/>
          <w:bottom w:val="single" w:sz="4" w:space="0" w:color="2E75B6"/>
          <w:right w:val="single" w:sz="4" w:space="0" w:color="2E75B6"/>
          <w:insideH w:val="single" w:sz="1" w:space="0" w:color="{BRD_COLOR}"/>
          <w:insideV w:val="single" w:sz="1" w:space="0" w:color="{BRD_COLOR}"/>
        </w:tblBorders>
        <w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>
      </w:tblPr>
      <w:tblGrid>{gridcols}</w:tblGrid>
{row(["Cycle","PC","Assembly","Operation","Result","Comment"], HDR_FILL, header=True)}"""

for i, r in enumerate(rows):
    fill = ODD_FILL if i % 2 == 0 else EVN_FILL
    tbl += row(list(r), fill)
tbl += "\n    </w:tbl>"

cap = """    <w:p w14:paraId="BB100003" w14:textId="77777777" w:rsidR="00D4211B" w:rsidRDefault="00000000">
      <w:pPr>
        <w:spacing w:before="60" w:after="160"/>
        <w:jc w:val="center"/>
        <w:rPr><w:rFonts w:ascii="Trebuchet MS" w:hAnsi="Trebuchet MS"/><w:color w:val="595959"/><w:sz w:val="19"/><w:szCs w:val="19"/></w:rPr>
      </w:pPr>
      <w:r>
        <w:rPr><w:rFonts w:ascii="Trebuchet MS" w:hAnsi="Trebuchet MS"/><w:color w:val="595959"/><w:sz w:val="19"/><w:szCs w:val="19"/></w:rPr>
        <w:t>Table 4.1 &#x2014; Step-by-step MIPS instruction execution verified against ModelSim waveform. Each row is one clock cycle. The Comment column explains datapath behaviour and relevant control signals activated for each instruction type.</w:t>
      </w:r>
    </w:p>"""

title_p = """    <w:p w14:paraId="BB100001" w14:textId="77777777" w:rsidR="00D4211B" w:rsidRDefault="00000000">
      <w:pPr>
        <w:spacing w:before="200" w:after="60"/>
        <w:rPr><w:rFonts w:ascii="Trebuchet MS" w:hAnsi="Trebuchet MS"/><w:b/><w:bCs/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr>
      </w:pPr>
      <w:r>
        <w:rPr><w:rFonts w:ascii="Trebuchet MS" w:hAnsi="Trebuchet MS"/><w:b/><w:bCs/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr>
        <w:t>Table 4.1 &#x2014; MIPS Processor Simulation: Step-by-Step Results with Comments</w:t>
      </w:r>
    </w:p>"""

with open(r'C:\Users\USER\Documents\MIPS_Project\table_insert.xml', 'w', encoding='utf-8') as f:
    f.write(title_p + "\n" + tbl + "\n" + cap)
print("Done:", len(title_p)+len(tbl)+len(cap), "chars")
