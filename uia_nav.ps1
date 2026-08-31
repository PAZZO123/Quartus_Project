Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Automation;

public class UINav {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    public static void MinimizeWnd(IntPtr h) { ShowWindow(h, 6); Thread.Sleep(150); }
    public static void ForceFront(IntPtr hWnd) {
        IntPtr fg = GetForegroundWindow();
        uint pid; uint fgT = GetWindowThreadProcessId(fg, out pid);
        uint myT = GetCurrentThreadId();
        AttachThreadInput(myT, fgT, true);
        BringWindowToTop(hWnd); ShowWindow(hWnd, 3); SetForegroundWindow(hWnd);
        Thread.Sleep(200);
        AttachThreadInput(myT, fgT, false);
    }
    public static bool IsFg(IntPtr h) { return GetForegroundWindow() == h; }
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

$log = @()

# Minimize Chrome
$chromes = Get-Process | Where-Object { $_.Name -like "*chrome*" -and $_.MainWindowHandle -ne [IntPtr]::Zero }
foreach ($c in $chromes) { [UINav]::MinimizeWnd($c.MainWindowHandle) }
Start-Sleep -Milliseconds 400

# Focus Quartus
$proc = Get-Process -Id 49136
[UINav]::ForceFront($proc.MainWindowHandle)
Start-Sleep -Milliseconds 600

$isFg = [UINav]::IsFg($proc.MainWindowHandle)
$log += "Focus: $isFg"

if ($isFg) {
    # Find Quartus window via UIAutomation
    $condition = [System.Windows.Automation.PropertyCondition]::new(
        [System.Windows.Automation.AutomationElement]::ProcessIdProperty, $proc.Id)
    $quartusEl = [System.Windows.Automation.AutomationElement]::RootElement.FindFirst(
        [System.Windows.Automation.TreeScope]::Children, $condition)
    
    if ($quartusEl -ne $null) {
        $log += "Found Quartus element: $($quartusEl.Current.Name)"
        
        # Find the menu bar
        $menuBarCond = [System.Windows.Automation.PropertyCondition]::new(
            [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
            [System.Windows.Automation.ControlType]::MenuBar)
        $menuBar = $quartusEl.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $menuBarCond)
        
        if ($menuBar -ne $null) {
            $log += "Found menu bar"
            
            # Find "Tools" menu item
            $toolsCond = [System.Windows.Automation.PropertyCondition]::new(
                [System.Windows.Automation.AutomationElement]::NameProperty, "Tools")
            $toolsItem = $menuBar.FindFirst([System.Windows.Automation.TreeScope]::Children, $toolsCond)
            
            if ($toolsItem -ne $null) {
                $log += "Found Tools menu"
                
                # Expand the Tools menu
                $expandPattern = $toolsItem.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)
                $expandPattern.Expand()
                Start-Sleep -Milliseconds 600
                
                $log += "Expanded Tools menu"
            } else {
                $log += "Tools menu NOT FOUND"
                # List all children of menubar
                $children = $menuBar.FindAll([System.Windows.Automation.TreeScope]::Children, [System.Windows.Automation.Condition]::TrueCondition)
                foreach ($ch in $children) { $log += "  Child: '$($ch.Current.Name)'" }
            }
        } else {
            $log += "Menu bar NOT FOUND"
        }
    } else {
        $log += "Quartus element NOT FOUND"
    }
}

$log | Out-File "C:\Users\USER\Documents\MIPS_Project\uia_log.txt"
