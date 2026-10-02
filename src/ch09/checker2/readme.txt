checker 2


note these conditions:

not
               if ( (CHARMSG(Msg,mp1,mp2).fs>0) and (KC_KEYUP>0)) then
but
               if (CHARMSG(Msg,mp1,mp2).fs and KC_KEYUP)>0 then


not
               if not( (CHARMSG(Msg,mp1,mp2).fs>0) and (KC_VIRTUALKEY>0) ) then
but
               if (not(CHARMSG(Msg,mp1,mp2).fs and KC_VIRTUALKEY))>0 then


and "mind the flow"


