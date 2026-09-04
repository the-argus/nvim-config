local present, precognition = pcall(require, "precognition")
if not present then
    return
end

-- :Precognition to toggle on and off
precognition.setup()
