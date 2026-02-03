--- Main Log window, holds tabs for different log types
--- @class ScribeLogger : ImguiLogger
--- @field Window ExtuiWindow
--- @field MainMenu ExtuiMenu
--- @field MenuFile ExtuiMenu
--- @field MainTabBar ExtuiTabBar
--- @field Ready boolean
ScribeLogger = _Class:Create("ScribeLogger", nil, {
    Ready = false,
})

function ScribeLogger:Init()
    self.Ready = false
    self:CreateWindow()
    self:InitializeLayout()
end

function ScribeLogger:CreateWindow()
    if self.Window ~= nil then return end -- only create once
    self.Window = Imgui.CreateCommonWindow("Scribe Log (WIP)", {
        IDContext = "Scribe_Log",
        -- defaults
        -- Size = {600, 550},
        -- MinSize = {500, 500},
        -- MaxSizePercentage = { 0.5, 0.85}
        -- Open = false,
        -- Closeable = true,
        -- AlwaysAutoResize = true
    })

    self.Window.OnClose = function(w)
        if w and w.UserData and w.UserData.Closed then
            w.UserData.Closed(w)
        end
    end

    -- Create MainMenu
    self.MainMenu = self.Window:AddMainMenu()
    self.MainMenu.UserData = {
        SubMenus = {},
        RegisterSubMenu = function(menu)
            self.MainMenu.UserData.SubMenus[menu.Handle] = menu
        end,
        ActivateSubMenu = function(menu)
            for _, v in pairs(self.MainMenu.UserData.SubMenus) do
                v.Visible = (v.Handle == menu.Handle)
            end
        end
    }
    self.MenuFile = self.MainMenu:AddMenu(Ext.Loca.GetTranslatedString("File", "File"))
    local openClose = self.MenuFile:AddItem(Ext.Loca.GetTranslatedString("Open/Close", "Open/Close"))
    openClose.OnClick = function(_)
        self.Window.Open = false
    end
end

function ScribeLogger:InitializeLayout()
    if self.Ready then return end -- only initialize once
    self.MainTabBar = self.Window:AddTabBar("Scribe_LoggerTabBar")
    -- self.MainTabBar.AutoSelectNewTabs = true

    -- Create tabs but defer logger initialization until first activation
    self.TabECS = self.MainTabBar:AddTabItem("ECS")
    self.TabECS.OnActivate = function()
        if not self.LoggerECS then
            self.LoggerECS = ImguiECSLogger:New {}
            self.LoggerECS:CreateTab(self.TabECS, self.MainMenu)
            self.MainMenu.UserData.ActivateSubMenu(self.LoggerECS.SettingsMenu)
        else
            -- If already initialized, just activate submenu
            if self.LoggerECS.SettingsMenu then
                self.MainMenu.UserData.ActivateSubMenu(self.LoggerECS.SettingsMenu)
            end
        end
    end

    self.TabServerEvents = self.MainTabBar:AddTabItem("Server Events")
    self.TabServerEvents.OnActivate = function()
        if not self.LoggerServerEvents then
            self.LoggerServerEvents = ImguiServerEventLogger:New {}
            self.LoggerServerEvents:CreateTab(self.TabServerEvents, self.MainMenu)
            if self.LoggerServerEvents.SettingsMenu then
                self.MainMenu.UserData.ActivateSubMenu(self.LoggerServerEvents.SettingsMenu)
            end
        else
            if self.LoggerServerEvents.SettingsMenu then
                self.MainMenu.UserData.ActivateSubMenu(self.LoggerServerEvents.SettingsMenu)
            end
        end
    end

    self.Ready = true
end
