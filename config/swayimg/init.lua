--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------

swayimg.exif_orientation = true
swayimg.antialiasing = true


--------------------------------------------------------------------------------
-- Image list
--------------------------------------------------------------------------------

swayimg.imagelist.order = "numeric"
swayimg.imagelist.reverse = false

-- Do not recurse into subdirectories.
swayimg.imagelist.recursive = false

-- When opening a single image, include other images from its directory.
swayimg.imagelist.adjacent = true

swayimg.imagelist.fsmon = true


--------------------------------------------------------------------------------
-- Text overlay
--------------------------------------------------------------------------------

swayimg.text.visible = true
swayimg.text.font = "monospace"

-- Smaller than the default configuration.
swayimg.text.size = 12

swayimg.text.spacing = 0
swayimg.text.padding = 8

swayimg.text.color = 0xffe1e1db
swayimg.text.background = 0x00000000
swayimg.text.shadow = 0x80000000

swayimg.text.timeout = 5
swayimg.text.status_timeout = 3


--------------------------------------------------------------------------------
-- Viewer
--------------------------------------------------------------------------------

swayimg.viewer.default_scale = "optimal"
swayimg.viewer.default_position = "center"

swayimg.viewer.autocenter = true
swayimg.viewer.loop = true

swayimg.viewer.preload = 1
swayimg.viewer.history = 1

swayimg.viewer.set_window_background(0xff313131)

swayimg.viewer.set_text("topleft", {
    "File:\t{name}",
    "Path:\t{path}",
    "Size:\t{sizehr}",
    "Image:\t{frame.width}x{frame.height}"
})

swayimg.viewer.set_text("topright", {
    "{list.index}/{list.total}"
})


--------------------------------------------------------------------------------
-- Viewer keybindings
--------------------------------------------------------------------------------

-- Quit.
swayimg.viewer.on_key("q", function()
    swayimg.exit()
end)

-- Return to gallery.
swayimg.viewer.on_key("Escape", function()
    swayimg.mode = "gallery"
end)

-- Return to gallery.
swayimg.viewer.on_key("Return", function()
    swayimg.mode = "gallery"
end)

-- Toggle information overlay.
swayimg.viewer.on_key("t", function()
    swayimg.text.visible = not swayimg.text.visible
end)

-- Temporary rotation only.
swayimg.viewer.on_key("[", function()
    swayimg.viewer.rotate(270)
end)

swayimg.viewer.on_key("]", function()
    swayimg.viewer.rotate(90)
end)

-- Delete deliberately does nothing.
swayimg.viewer.on_key("Delete", function()
end)

-- Permanently delete the current file from the hard drive:
swayimg.viewer.on_key("Shift+Delete", function()
    local img = swayimg.viewer.get_image()
    if img and img.path then
        os.remove(img.path)
        swayimg.imagelist.remove(img.path)
    end
end)

-- Show next and previous images directly
swayimg.viewer.on_key("space", function()
    swayimg.viewer.open("next")
end)

swayimg.viewer.on_key("Backspace", function()
    swayimg.viewer.open("prev")
end)

--------------------------------------------------------------------------------
-- Gallery
--------------------------------------------------------------------------------

swayimg.gallery.thumb_size = 180
swayimg.gallery.aspect = "keep"

swayimg.gallery.padding_size = 5
swayimg.gallery.border_size = 3
swayimg.gallery.selected_scale = 1.05

swayimg.gallery.cache = 100
swayimg.gallery.preload = false
swayimg.gallery.embedded_thumb = true
swayimg.gallery.pstore = false

swayimg.gallery.set_text("topleft", {
    "File:\t{name}",
    "Path:\t{path}"
})

swayimg.gallery.set_text("topright", {
    "{list.index}/{list.total}"
})


--------------------------------------------------------------------------------
-- Gallery keybindings
--------------------------------------------------------------------------------

-- Quit.
swayimg.gallery.on_key("q", function()
    swayimg.exit()
end)

-- Quit from gallery.
swayimg.gallery.on_key("Escape", function()
    swayimg.exit()
end)

-- Open selected image.
swayimg.gallery.on_key("Return", function()
    swayimg.mode = "viewer"
end)

-- Toggle information overlay.
swayimg.gallery.on_key("t", function()
    swayimg.text.visible = not swayimg.text.visible
end)

-- Vim-style navigation.
swayimg.gallery.on_key("h", function()
    swayimg.gallery.select("left")
end)

swayimg.gallery.on_key("j", function()
    swayimg.gallery.select("down")
end)

swayimg.gallery.on_key("k", function()
    swayimg.gallery.select("up")
end)

swayimg.gallery.on_key("l", function()
    swayimg.gallery.select("right")
end)

-- Arrow navigation.
swayimg.gallery.on_key("left", function()
    swayimg.gallery.select("left")
end)

swayimg.gallery.on_key("right", function()
    swayimg.gallery.select("right")
end)

swayimg.gallery.on_key("up", function()
    swayimg.gallery.select("up")
end)

swayimg.gallery.on_key("down", function()
    swayimg.gallery.select("down")
end)

-- Delete deliberately does nothing.
swayimg.gallery.on_key("Delete", function()
end)

-- Lossless rotation 90 degrees counter-clockwise (Left)
swayimg.viewer.on_key("[", function()
    local img = swayimg.viewer.get_image()
    if img and img.path then
        local cmd
        if string.match(img.path:lower(), "%.jpe?g$") then
            cmd = string.format("jpegtran -rotate 270 -copy all %q > %q.tmp && mv %q.tmp %q", img.path, img.path, img.path, img.path)
        else
            cmd = string.format("magick %q -rotate 270 %q", img.path, img.path)
        end
        os.execute(cmd)
        swayimg.viewer.reload()
    end
end)

-- Lossless rotation 90 degrees clockwise (Right)
swayimg.viewer.on_key("]", function()
    local img = swayimg.viewer.get_image()
    if img and img.path then
        local cmd
        if string.match(img.path:lower(), "%.jpe?g$") then
            cmd = string.format("jpegtran -rotate 90 -copy all %q > %q.tmp && mv %q.tmp %q", img.path, img.path, img.path, img.path)
        else
            cmd = string.format("magick %q -rotate 90 %q", img.path, img.path)
        end
        os.execute(cmd)
        swayimg.viewer.reload()
    end
end)
