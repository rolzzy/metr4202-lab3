function o=setup()

%Purpose: to initially setup the dynamixel motors

%% Initialise
dynamixel_id = 2;
o = MyDynamixel(dynamixel_id);
% o.viewSupportFcn();
o.portNum = 3;
o.baudNum = 1;
o.init()
o.addDevice(1);
o.addDevice(2);
o.addDevice(3);
%% Set Speed
o.setSpeed('id',3,'RPM',10);
o.setSpeed('id',2,'RPM',10);
o.setSpeed('id',1,'RPM',10);
%% Set Compliance
for i = 1:3
    calllib('dynamixel','dxl_write_word',o.Devices(i).id,ControlTable.CCWSlope,40);
    calllib('dynamixel','dxl_write_word',o.Devices(i).id,ControlTable.CWSlope,40);
    calllib('dynamixel','dxl_write_word',o.Devices(i).id,ControlTable.CCWMargin,1);
    calllib('dynamixel','dxl_write_word',o.Devices(i).id,ControlTable.CWMargin,1);
end
        
end