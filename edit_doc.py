import sys, re

path = r"C:\Users\USER\Documents\MIPS_Project\v3_unpacked\word\document.xml"
with open(path, encoding="utf-8") as f:
    doc = f.read()

# ---- 1. Update testbench description ----
doc = doc.replace(
    "The mips_processor_tb.sv testbench was executed in ModelSim ALTERA 10.1d with the following register pre-conditions: $t0 = 0x0, $t1 = 0x5, $t3 = 0xA, $t4 = 0x4. The instruction ROM (imem module) contains nine instructions covering all instruction types supported by the processor. Results are displayed one cycle after each posedge clock to allow combinational paths to settle.",
    "The mips_processor_tb.sv testbench was executed in ModelSim ALTERA 10.1d. The instruction ROM (imem) is pre-loaded with eight instructions covering every supported type: ADDI, ADD, SUB, ANDI, SW, LW, and BEQ. The program first loads constants via ADDI ($t0&#x2190;5, $t1&#x2190;10) so register values are visible as decimal numbers on the waveform bars from cycle 1. Results are sampled one clock edge after each posedge to allow combinational paths to settle."
)

# ---- 2. Update figure docPr ----
old_descr = 'Figure 4.9 — ModelSim ALTERA simulation of mips_processor_tb.sv (116 ns). All six instruction types execute correctly: SUB(10−4=6), AND(0&amp;5=0), OR(0|5=5), SLT(10&lt;4=0), LW(addr=4), SW(addr=0). BEQ correctly branches from PC=0x1c to 0x28, skipping one instruction.'
new_descr = 'Figure 4.9 — ModelSim ALTERA 10.1d waveform of mips_processor_tb.sv (316 ns). REGISTER FILE (decimal) shows: $t0=5 (ADDI), $t1=10 (ADDI), $t2=15 (ADD 5+10), $t3=5 (SUB 10−5), $t4=1 (ANDI 5&amp;3), $s0=15 (LW). BEQ at PC=0x1c branches to 0x24 (zero=1, pcsrc=1). All instruction types verified.'
doc = doc.replace(old_descr, new_descr)

# ---- 3. Update figure caption text ----
doc = doc.replace(
    "Figure 4.9 — ModelSim ALTERA simulation of mips_processor_tb.sv (116 ns). All six instruction types execute correctly: SUB(10−4=6), AND(0&amp;5=0), OR(0|5=5), SLT(10&lt;4=0), LW(addr=4), SW(addr=0). BEQ correctly branches from PC=0x1c to 0x28, skipping one instruction.",
    "Figure 4.9 — ModelSim ALTERA 10.1d waveform of mips_processor_tb.sv (316 ns). The REGISTER FILE (decimal) section shows each register acquiring its value cycle by cycle: $t0=5 (ADDI), $t1=10 (ADDI), $t2=15 (ADD 5+10), $t3=5 (SUB 10−5), $t4=1 (ANDI 5&amp;3=1), $s0=15 (LW from Mem[0]). BEQ at PC=0x1c detects zero=1 and jumps to PC=0x24, skipping the NOP at 0x20."
)

# ---- 4. Update key observations ----
doc = doc.replace(
    "Key observations: (1) SUB $t5,$t3,$t4 correctly computes 10−4 = 6. (2) AND and OR produce 0 and 5 respectively with $t0=0. (3) SLT returns 0 since 10 is not less than 4. (4) The BEQ instruction at PC=0x1c detects equality (0==0) and advances PC by 12 bytes to 0x28, bypassing PC=0x20 and 0x24, confirming correct branch resolution.",
    "Key observations: (1) ADDI at cycles 1–2 loads 5 and 10 into $t0/$t1 — values appear as decimal numbers on the waveform bars. (2) ADD at cycle 3 gives $t2=15 (5+10), ALUcontrol=010. (3) SUB at cycle 4 gives $t3=5 (10−5), ALUcontrol=110. (4) ANDI at cycle 5 gives $t4=1 (0101₂ &amp; 0011₂ = 0001₂), ALUcontrol=000. (5) SW writes $t2=15 to Mem[0] (memwrite=1). (6) LW at cycle 7 reads Mem[0]=15 into $s0 (memtoreg=1). (7) BEQ at cycle 8 detects $t0==$t0 (zero=1, pcsrc=1) and jumps to PC=0x24."
)

# ---- 5. Build & insert Table 4.1 with Comment column ----
cols = [500, 700, 1760, 1400, 1000, 4000]  # total=9360
HDR  = "1F4E79"
ODD  = "EBF3FB"
EVN  = "FFFFFF"
BC   = "BFBFBF"
F    = "Trebuchet MS"

def bd():
    s = f'w:val="single" w:sz="1" w:space="0" w:color="{BC}"'
    return f'<w:top {s}/><w:left {s}/><w:bottom {s}/><w:right {s}/>'

def tc(txt, w, fill, bold=False, white=False, ctr=False, sz=17):
    jc = "center" if ctr else "left"
    col = "FFFFFF" if white else "000000"
    bb = "<w:b/><w:bCs/>" if bold else ""
    return f"""        <w:tc>
          <w:tcPr>
            <w:tcW w:w="{w}" w:type="dxa"/>
            <w:tcBorders>{bd()}</w:tcBorders>
            <w:shd w:val="clear" w:color="auto" w:fill="{fill}"/>
            <w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="100" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="100" w:type="dxa"/></w:tcMar>
            <w:vAlign w:val="center"/>
          </w:tcPr>
          <w:p><w:pPr><w:jc w:val="{jc}"/><w:rPr><w:rFonts w:ascii="{F}" w:hAnsi="{F}"/></w:rPr></w:pPr>
          <w:r><w:rPr><w:rFonts w:ascii="{F}" w:hAnsi="{F}"/>{bb}<w:color w:val="{col}"/><w:sz w:val="{sz}"/><w:szCs w:val="{sz}"/></w:rPr>
          <w:t xml:space="preserve">{txt}</w:t></w:r></w:p>
        </w:tc>"""

def tr(cells, fill, hdr=False):
    th = "<w:tblHeader/>" if hdr else ""
    tcs = "".join(tc(t,w,fill,bold=hdr,white=hdr,ctr=(i<2),sz=17) for i,(t,w) in enumerate(zip(cells,cols)))
    return f"""      <w:tr><w:tblPrEx><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPrEx>
        <w:trPr>{th}</w:trPr>
{tcs}
      </w:tr>"""

data = [
  ("1","0x0000","addi $t0,$zero,5",  "$t0 &#x2190; 0+5",          "R[8]=5",    "I-type ADDI: imm=5 sign-extended, added to $zero; alusrc=1, regwrite=1, regdst=0"),
  ("2","0x0004","addi $t1,$zero,10", "$t1 &#x2190; 0+10",         "R[9]=10",   "I-type ADDI: loads constant 10; visible as decimal on waveform bar from this cycle"),
  ("3","0x0008","add $t2,$t0,$t1",   "$t2 &#x2190; 5+10",         "R[10]=15",  "R-type ADD: ALUcontrol=010; regdst=1 (rd=destination), alusrc=0 (register B used)"),
  ("4","0x000C","sub $t3,$t1,$t0",   "$t3 &#x2190; 10&#x2212;5",  "R[11]=5",   "R-type SUB: ALUcontrol=110; two&#x2019;s complement, B inverted then +1 added"),
  ("5","0x0010","andi $t4,$t0,0x3",  "$t4 &#x2190; 5 &amp; 3",   "R[12]=1",   "I-type ANDI: 0101&#x2082;&amp;0011&#x2082;=0001&#x2082;=1; aluop=11&#x2192;ALUcontrol=000 (forced AND)"),
  ("6","0x0014","sw $t2,0($zero)",   "Mem[0]&#x2190;$t2",         "Mem[0]=15", "SW: ALU addr=0+0=0; memwrite=1, writedata=$t2=15 written to data memory word 0"),
  ("7","0x0018","lw $s0,0($zero)",   "$s0 &#x2190; Mem[0]",       "R[16]=15",  "LW: addr=0, readdata=0x0F=15; memtoreg=1 routes memory read to register write-back"),
  ("8","0x001C","beq $t0,$t0,+1",    "if $t0==$t0 branch+1",      "PC=0x0024", "BEQ: ALU computes $t0&#x2212;$t0=0, zero=1, pcsrc=1; PC+12=0x24 (NOP at 0x20 skipped)"),
  ("9+","0x0024","nop (skipped)",    "no operation",               "&#x2014;",  "Post-branch idle; registers and memory hold final values: $t0=5,$t1=10,$t2=15,$s0=15"),
]

gc = "".join(f'<w:gridCol w:w="{c}"/>' for c in cols)
tbl = f"""    <w:tbl>
      <w:tblPr>
        <w:tblStyle w:val="TableGrid"/>
        <w:tblW w:w="9360" w:type="dxa"/>
        <w:tblBorders>
          <w:top w:val="single" w:sz="4" w:space="0" w:color="2E75B6"/>
          <w:left w:val="single" w:sz="4" w:space="0" w:color="2E75B6"/>
          <w:bottom w:val="single" w:sz="4" w:space="0" w:color="2E75B6"/>
          <w:right w:val="single" w:sz="4" w:space="0" w:color="2E75B6"/>
          <w:insideH w:val="single" w:sz="1" w:space="0" w:color="{BC}"/>
          <w:insideV w:val="single" w:sz="1" w:space="0" w:color="{BC}"/>
        </w:tblBorders>
        <w:tblLook w:val="0000"/>
      </w:tblPr>
      <w:tblGrid>{gc}</w:tblGrid>
{tr(["Cycle","PC (hex)","Assembly Instruction","Operation","Result","Comment"], HDR, hdr=True)}"""
for i,r in enumerate(data):
    tbl += tr(list(r), ODD if i%2==0 else EVN)
tbl += "\n    </w:tbl>"

title_p = """    <w:p w14:paraId="0B100001" w14:textId="77777777" w:rsidR="00D4211B" w:rsidRDefault="00000000">
      <w:pPr><w:spacing w:before="200" w:after="60"/>
        <w:rPr><w:rFonts w:ascii="Trebuchet MS" w:hAnsi="Trebuchet MS"/><w:b/><w:bCs/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr>
      </w:pPr>
      <w:r><w:rPr><w:rFonts w:ascii="Trebuchet MS" w:hAnsi="Trebuchet MS"/><w:b/><w:bCs/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr>
        <w:t>Table 4.1 — MIPS Processor Simulation: Step-by-Step Results with Comments</w:t>
      </w:r>
    </w:p>"""

cap_p = """    <w:p w14:paraId="0B100003" w14:textId="77777777" w:rsidR="00D4211B" w:rsidRDefault="00000000">
      <w:pPr><w:spacing w:before="60" w:after="160"/><w:jc w:val="center"/>
        <w:rPr><w:rFonts w:ascii="Trebuchet MS" w:hAnsi="Trebuchet MS"/><w:color w:val="595959"/><w:sz w:val="19"/><w:szCs w:val="19"/></w:rPr>
      </w:pPr>
      <w:r><w:rPr><w:rFonts w:ascii="Trebuchet MS" w:hAnsi="Trebuchet MS"/><w:color w:val="595959"/><w:sz w:val="19"/><w:szCs w:val="19"/></w:rPr>
        <w:t>Table 4.1 — Each row is one clock cycle. The Comment column explains which datapath elements and control signals are active for each instruction type, verified against ModelSim waveform output.</w:t>
      </w:r>
    </w:p>"""

insert = title_p + "\n" + tbl + "\n" + cap_p + "\n"

marker = '<w:p w14:paraId="0873B59E"'
idx = doc.index(marker)
doc = doc[:idx] + insert + doc[idx:]

# Write UTF-8 WITHOUT BOM
enc = __import__("codecs").lookup("utf-8-sig")   # utf-8-sig reads/writes BOM
# Use plain utf-8
with open(path, "w", encoding="utf-8", newline="") as f:
    f.write(doc)
print(f"Written {len(doc)} chars, BOM={doc[:3]==chr(0xFEFF)}")
