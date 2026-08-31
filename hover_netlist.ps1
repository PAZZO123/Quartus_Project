Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
public class WA6 {
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, int dwExtraInfo);
    public static void Click(int x, int y) {
        SetCursorPos(x, y); Thread.Sleep(150);
        mouse_event(2, (uint)x, (uint)y, 0, 0);
        Thread.Sleep(100);
        mouse_event(4, (uint)x, (uint)y, 0, 0);
        Thread.Sleep(150);
    }
    public static void Move(int x, int y) {
        SetCursorPos(x, y); Thread.Sleep(200);
    }
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Tools menu is open. Click on "Netlist Viewers" at approximately y=181
# The menu appears to be around x=248 to x=415, items at x≈320
[WA6]::Move(320, 181)
Start-Sleep -Milliseconds 500

[int]$w = 1920; [int]$h = 1080
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen(0, 0, 0, 0, (New-Object System.Drawing.Size($w, $h)))
$g.Dispose()
$bmp.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_hover_netlist.png")
$bmp.Dispose()
