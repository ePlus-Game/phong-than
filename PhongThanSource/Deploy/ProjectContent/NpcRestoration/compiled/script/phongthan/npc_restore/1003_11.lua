-- AUTHORED NPC 1003_11; not a claim of original appearance.
function pt_guard()
    local w = GetWorldPos()
    if w ~= 1003 then CloseDialog(); return 0 end
    return 1
end
function main()
    if pt_guard() == 0 then return end
    Say("L\183o R\239a - Ng\228c H\173 Cung (212/203)", 4, "Vai tr\223 v\181 h\173\237ng d\201n/pt_about", "NPC li\170n quan/pt_routes", "Tr\185ng th\184i ch\248c n\168ng/pt_status", "\167\227ng/pt_close")
end
function pt_about()
    if pt_guard() == 0 then return end
    Say("\167\199u m\232i L\183o R\239a \174\173\238c t\184i d\249ng theo danh m\244c \174\183 duy\214t. C\227 th\211 h\225i \174\222a ch\216 v\181 tra c\248u nh\247ng NPC li\170n quan trong b\182n \174\229.", 2, "Quay l\185i/main", "\167\227ng/pt_close")
end
function pt_routes()
    if pt_guard() == 0 then return end
    Say("Kim Ha Dong Tu (212/204); Th\173\172ng Nh\169n T\169y V\249c (212/202); Sinh Ho\185t S\173 (217/202); Xich Tinh Tu (213/197); Chuy\211n Sinh L\183o L\183o (212/196)", 2, "Quay l\185i/main", "\167\227ng/pt_close")
end
function pt_status()
    if pt_guard() == 0 then return end
    Say("\167ang m\235: \174\232i tho\185i, h\173\237ng d\201n v\181 tra c\248u. Nh\203n/tr\182 nhi\214m v\244, \174\230i th\173\235ng v\181 giao d\222ch ch\173a m\235 khi ch\173a \174\241 m\183 d\247 li\214u.", 2, "Quay l\185i/main", "\167\227ng/pt_close")
end
function pt_close()
    CloseDialog()
end
