-- AUTHORED NPC 1002_19; not a claim of original appearance.
function pt_guard()
    local w = GetWorldPos()
    if w ~= 1002 then CloseDialog(); return 0 end
    return 1
end
function main()
    if pt_guard() == 0 then return end
    Say("L\183o R\239a - S\239ng Th\181nh Doanh (202/197)", 4, "Vai tr\223 v\181 h\173\237ng d\201n/pt_about", "NPC li\170n quan/pt_routes", "Tr\185ng th\184i ch\248c n\168ng/pt_status", "\167\227ng/pt_close")
end
function pt_about()
    if pt_guard() == 0 then return end
    Say("\167\199u m\232i L\183o R\239a \174\173\238c t\184i d\249ng theo danh m\244c \174\183 duy\214t. C\227 th\211 h\225i \174\222a ch\216 v\181 tra c\248u nh\247ng NPC li\170n quan trong b\182n \174\229.", 2, "Quay l\185i/main", "\167\227ng/pt_close")
end
function pt_routes()
    if pt_guard() == 0 then return end
    Say("Th\241 Kho (202/198); Chuy\211n Sinh L\183o L\183o (202/199); T\169n Th\241 Th\221 Luy\214n (200/199); Th\173\172ng Nh\169n T\169y V\249c (199/199); \162u Thi\170n H\227a (206/196)", 2, "Quay l\185i/main", "\167\227ng/pt_close")
end
function pt_status()
    if pt_guard() == 0 then return end
    Say("\167ang m\235: \174\232i tho\185i, h\173\237ng d\201n v\181 tra c\248u. Nh\203n/tr\182 nhi\214m v\244, \174\230i th\173\235ng v\181 giao d\222ch ch\173a m\235 khi ch\173a \174\241 m\183 d\247 li\214u.", 2, "Quay l\185i/main", "\167\227ng/pt_close")
end
function pt_close()
    CloseDialog()
end
