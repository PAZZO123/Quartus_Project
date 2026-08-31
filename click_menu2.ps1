Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
public class WA2 {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, int dwExtraInfo);
    [DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);
    
    public static void ForceFront(IntPtr hWnd) {
        IntPtr fg = GetForegroundWindow();
        uint pid; uint fgT = GetWindowThreadProcessId(fg, out pid);
        uint myT = GetCurrentThreadId();
        AttachThreadInput(myT, fgT, true);
        BringWindowToTop(hWnd); ShowWindow(hWnd, 3); SetForegroundWindow(hWnd);
        AttachThreadInput(myT, fgT, false);
    }
    public static void Click(int x, int y) {
        SetCursorPos(x, y); Thread.Sleep(120);
        mouse_event(2, (uint)x, (uint)y, 0, 0);
        Thread.Sleep(80);
        mouse_event(4, (uint)x, (uint)y, 0, 0);
        Thread.Sleep(100);
    }
    public static void PressEsc() {
        keybd_event(0x1B, 0, 0, 0); Thread.Sleep(50); keybd_event(0x1B, 0, 2, 0);
    }
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

$proc = Get-Process -Id 49136
[WA2]::ForceFront($proc.MainWindowHandle)
Start-Sleep -Milliseconds 400

# Press Escape to close any open menu
[WA2]::PressEsc()
Start-Sleep -Milliseconds 300

# Zoom into menu bar to find exact x of "Tools"
$bmp = New-Object System.Drawing.Bitmap(1920, 1080)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen(0, 0, 0, 0, (New-Object System.Drawing.Size(1920, 1080)))
$g.Dispose()

# Save a zoom of the menu bar area
$zoom = New-Object System.Drawing.Bitmap(600, 40)
$gz = [System.Drawing.Graphics]::FromImage($zoom)
$gz.DrawImage($bmp, [System.Drawing.Rectangle]::new(0, 0, 600, 40), [System.Drawing.Rectangle]::new(0, 15, 600, 40), [System.Drawing.GraphicsUnit]::Pixel)
$gz.Dispose()
$zoom.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_menubar_zoom.png")
$bmp.Dispose(); $zoom.Dispose()
