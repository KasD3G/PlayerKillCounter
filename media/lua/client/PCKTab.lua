BoxTab = ISCollapsableWindow:derive("PKC");

function BoxTab:initialise()
    ISCollapsableWindow.initialise(self);
end

function DrawBox()
    BoxTab = BoxTab:new(70, 0, 250, 95)
    BoxTab:addToUIManager();
    BoxTab.pin = false;
    BoxTab.resizable = true;
    BoxTab:setVisible(true);
    PKCMain.updateUI();
end

function BoxTab:new(x, y, w, h)
    local stats = {};
    stats = ISCollapsableWindow:new(x, y, w, h);
    setmetatable(stats, self);
    self.__index = self;
    stats.title = "Player kill count";
    stats.pin = false;
    stats:noBackground();
    return stats;
end

function BoxTab:createChildren()
    ISCollapsableWindow.createChildren(self);
    self.HomeWindow = ISRichTextPanel:new(0, 16, 250, 87);
    self.HomeWindow:initialise();
    self.HomeWindow.autosetheight = true;
    self:addChild(self.HomeWindow);
end

Events.OnGameStart.Add(DrawBox);