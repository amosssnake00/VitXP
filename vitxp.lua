local mq = require('mq')

local hp_floor = 25
local hp_ceil = 60
local debug = false --  less spam
local myname = mq.TLO.Me.CleanName()

local function set_vxp(state_vxp)
    local fsw = mq.TLO.Window('FellowshipWnd')
    if (state_vxp ~= false) or state_vxp == nil then state_vxp = true end
    fsw.DoOpen()
    mq.delay(50)
    fsw.Child('FP_Subwindows').SetCurrentTab(1)
    mq.delay(50)
    if (fsw.Child('FP_MemberList').List(fsw.Child('FP_MemberList').List(myname,1),7)() == "Not sharing" and state_vxp == true) or (fsw.Child('FP_MemberList').List(fsw.Child('FP_MemberList').List(myname,1),7)() == "Sharing" and state_vxp == false) then
        if debug then
            print('current setting: '..fsw.Child('FP_MemberList').List(fsw.Child('FP_MemberList').List(myname,1),7)())
            print('setting VXP to '..tostring(state_vxp))
            print('VXP at '..tostring(mq.TLO.Me.Vitality())..' - AAVXP at '..tostring(mq.TLO.Me.AAVitality()))
            print('-------------------------------------->')
        end
        fsw.Child('FP_MemberList').Select(fsw.Child('FP_MemberList').List(myname,1))
        mq.delay(50)
        fsw.Child('FP_ToggleExpSharingButton').LeftMouseDown()
        mq.delay(50)
        fsw.Child('FP_ToggleExpSharingButton').LeftMouseUp()
        mq.delay(50)
    end
    fsw.DoClose()
    mq.delay(50)
end

local function condition()
    local x_floor = 100
    if mq.TLO.Me.XTarget() > 0 then
        for i = 1, mq.TLO.Me.XTarget() do
            if mq.TLO.Me.XTarget(i).Aggressive() and mq.TLO.Me.XTarget(i).PctHPs() < x_floor then x_floor = mq.TLO.Me.XTarget(i).PctHPs() end
        end
    end
    if (mq.TLO.Me.Fellowship.Member(myname).Sharing() and x_floor > hp_ceil) or (not mq.TLO.Me.Fellowship.Member(myname).Sharing() and ((x_floor < hp_floor) or (not mq.TLO.Me.XTarget() == 0))) then 
        return true
    else
        return false
    end
    -- old condition
    -- return (mq.TLO.Target() and mq.TLO.Target.Aggressive() and mq.TLO.Target.PctHPs() < hp_floor and mq.TLO.Me.Fellowship.Member(myname).Sharing()) or (not mq.TLO.Me.Fellowship.Member(myname).Sharing() and (not mq.TLO.Target() or (mq.TLO.Target.Aggressive() and mq.TLO.Target.PctHPs() > hp_ceil))) or (mq.TLO.Target() and mq.TLO.Target.Dead() and not mq.TLO.Me.Fellowship.Member(myname).Sharing())
end

local function action()
    if debug then
        print('<--------------------------------------')
        print('')
        print('Sharing: '..tostring(mq.TLO.Me.Fellowship.Member(myname).Sharing()))
        print('Target: '..tostring(mq.TLO.Target()))
        print('Target Agressive: '..tostring(mq.TLO.Target.Aggressive()))
        print('Target HP: '..tostring(mq.TLO.Target.PctHPs()))
        print('floor/ceil: '..hp_floor..'/'..hp_ceil)
    end
           set_vxp(not mq.TLO.Me.Fellowship.Member(myname).Sharing())
    mq.delay(500)
end   
  
local function main()
    print('starting...')
    if not mq.TLO.Me.Fellowship() then 
        print('You need to be in a fellowship to use this tool!')
        error('NO_FELLOWSHIP')
    end
    set_vxp(true)
    while true do
        if condition() then
          action()
        end
        mq.delay(500)
      end
end

main()
