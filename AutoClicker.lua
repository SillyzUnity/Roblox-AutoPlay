local VirtualInputManager = game:GetService("VirtualInputManager")

-- Simulated click at a fixed position (165, 250)
coroutine.wrap(function()
    while true do
        -- Move the circle to the target position (simulate mouse movement)
        -- (In case you want to visualize the position of the click)
        local circlePosition = Vector2.new(0, 0)

        -- Simulate mouse button down
        VirtualInputManager:SendMouseButtonEvent(circlePosition.X, circlePosition.Y, 0, true, game, 0)
        task.wait(0.1)  -- Keep it pressed for 0.2 seconds

        -- Simulate mouse button up
        VirtualInputManager:SendMouseButtonEvent(circlePosition.X, circlePosition.Y, 0, false, game, 0)
        task.wait(0.01)  -- Wait for the next click
    end
end)()
