--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------

swayimg.exif_orientation = true

-- Keep enabled for image quality.
-- Set to false if gallery scrolling remains slow with very large images.
swayimg.antialiasing = true


--------------------------------------------------------------------------------
-- Image list
--------------------------------------------------------------------------------

swayimg.imagelist.order = "numeric"
swayimg.imagelist.reverse = false

-- Do not include images from nested directories automatically.
swayimg.imagelist.recursive = false

-- When opening one image, include the other images in the same directory.
swayimg.imagelist.adjacent = true

-- Monitor the current folder for added or removed files.
swayimg.imagelist.fsmon = true


--------------------------------------------------------------------------------
-- Text overlay
--------------------------------------------------------------------------------

swayimg.text.visible = true
swayimg.text.font = "monospace"
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

-- Keep a small number of neighbouring images loaded.
-- Increase to 2 or 3 if you have enough memory and want faster next/previous
-- navigation. Keep it at 1 for lower memory use.
swayimg.viewer.preload = 2

swayimg.viewer.history = 1

swayimg.viewer.set_window_background(0xff313131)


--------------------------------------------------------------------------------
-- Viewer keybindings
--------------------------------------------------------------------------------

-- Quit.
swayimg.viewer.on_key("q", function()
    swayimg.exit()
end)

-- Return to the gallery.
swayimg.viewer.on_key("Escape", function()
    swayimg.mode = "gallery"
end)

swayimg.viewer.on_key("Return", function()
    swayimg.mode = "gallery"
end)

-- Toggle the filename / metadata overlay.
swayimg.viewer.on_key("t", function()
    swayimg.text.visible = not swayimg.text.visible
end)

--------------------------------------------------------------------------------
-- Viewer navigation
--------------------------------------------------------------------------------

-- Vim-style previous image.
swayimg.viewer.on_key("h", function()
    swayimg.viewer.open("prev")
end)

-- Vim-style next image.
-- j and l both move forward, similar to common image-viewer workflows.
swayimg.viewer.on_key("j", function()
    swayimg.viewer.open("next")
end)

swayimg.viewer.on_key("l", function()
    swayimg.viewer.open("next")
end)

-- k moves to the previous image.
swayimg.viewer.on_key("k", function()
    swayimg.viewer.open("prev")
end)

-- Keep your existing convenient navigation keys.
swayimg.viewer.on_key("space", function()
    swayimg.viewer.open("next")
end)

swayimg.viewer.on_key("Backspace", function()
    swayimg.viewer.open("prev")
end)

-- Arrow-key navigation.
swayimg.viewer.on_key("left", function()
    swayimg.viewer.open("prev")
end)

swayimg.viewer.on_key("right", function()
    swayimg.viewer.open("next")
end)


--------------------------------------------------------------------------------
-- Viewer file deletion
--------------------------------------------------------------------------------

-- Delete does nothing deliberately.
-- This prevents accidental permanent deletion.
swayimg.viewer.on_key("Delete", function()
end)

-- Shift+Delete permanently removes the currently open file.
-- This is irreversible unless you have a backup.
swayimg.viewer.on_key("Shift+Delete", function()
    local img = swayimg.viewer.get_image()

    if img and img.path then
        os.remove(img.path)
        swayimg.imagelist.remove(img.path)
    end
end)


--------------------------------------------------------------------------------
-- Viewer permanent rotation
--------------------------------------------------------------------------------

-- Requires:
--   sudo pacman -S libjpeg-turbo imagemagick
--
-- JPEG files use jpegtran for lossless rotation and preserve EXIF data.
-- Other supported image formats use ImageMagick.

-- Rotate 90 degrees counter-clockwise.
swayimg.viewer.on_key("[", function()
    local img = swayimg.viewer.get_image()

    if not img or not img.path then
        return
    end

    local command

    if string.match(img.path:lower(), "%.jpe?g$") then
        command = string.format(
            "jpegtran -rotate 270 -copy all %q > %q.tmp && mv %q.tmp %q",
            img.path,
            img.path,
            img.path,
            img.path
        )
    else
        command = string.format(
            "magick %q -rotate 270 %q",
            img.path,
            img.path
        )
    end

    os.execute(command)
    swayimg.viewer.reload()
end)

-- Rotate 90 degrees clockwise.
swayimg.viewer.on_key("]", function()
    local img = swayimg.viewer.get_image()

    if not img or not img.path then
        return
    end

    local command

    if string.match(img.path:lower(), "%.jpe?g$") then
        command = string.format(
            "jpegtran -rotate 90 -copy all %q > %q.tmp && mv %q.tmp %q",
            img.path,
            img.path,
            img.path,
            img.path
        )
    else
        command = string.format(
            "magick %q -rotate 90 %q",
            img.path,
            img.path
        )
    end

    os.execute(command)
    swayimg.viewer.reload()
end)


--------------------------------------------------------------------------------
-- Gallery
--------------------------------------------------------------------------------

-- Smaller thumbnails reduce decoding and scaling work.
-- 160 is a useful compromise for 1080p displays.
swayimg.gallery.thumb_size = 160

swayimg.gallery.aspect = "keep"

swayimg.gallery.padding_size = 5
swayimg.gallery.border_size = 3

-- Disable thumbnail enlargement for smoother navigation.
swayimg.gallery.selected_scale = 1.0

-- Cache more thumbnails to reduce re-decoding while moving around a folder.
-- If memory use becomes excessive, lower this to 250.
swayimg.gallery.cache = 500

-- Avoid loading thumbnails that are not currently needed.
swayimg.gallery.preload = false

-- Use embedded JPEG thumbnails where available. This improves speed for
-- photos directly copied from many cameras and phones.
swayimg.gallery.embedded_thumb = true

-- Keep disabled unless you want persistent thumbnail caching.
swayimg.gallery.pstore = false


--------------------------------------------------------------------------------
-- Gallery keybindings
--------------------------------------------------------------------------------

-- Quit.
swayimg.gallery.on_key("q", function()
    swayimg.exit()
end)

swayimg.gallery.on_key("Escape", function()
    swayimg.exit()
end)

-- Open the selected image.
swayimg.gallery.on_key("Return", function()
    swayimg.mode = "viewer"
end)

-- Toggle filename / metadata overlay.
swayimg.gallery.on_key("t", function()
    swayimg.text.visible = not swayimg.text.visible
end)

--------------------------------------------------------------------------------
-- Gallery navigation
--------------------------------------------------------------------------------

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

-- Arrow-key navigation.
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

swayimg.gallery.on_key("Shift+g", function()
    swayimg.gallery.select("last")
end)

local last_g_press = 0
local gg_timeout = 0.45

swayimg.gallery.on_key("g", function()
    local now = os.clock()

    if now - last_g_press <= gg_timeout then
        swayimg.gallery.select("first")
        last_g_press = 0
    else
        last_g_press = now
    end
end)

-- Do nothing on Delete to prevent accidental removal.
swayimg.gallery.on_key("Delete", function()
end)
