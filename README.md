# BodyGuard - A new Role for TTT2

The BodyGuard is a special case. Once he Spawns, he will get a random Player dedicated for him to protect and is also in the same Team as this Player.
He will get a message which also reveals the Role of the Player he needs to protect. BUT, the BodyGuard will NOT see the other Players in the Team he is (so as Traitor he will not see other Traitors).
Also the Player he needs to protect will get a message that a Player is his BodyGuard.
Goal is to protect the Player you are dedicated to.

If the Player you need to protect dies, you will get some damage (or die depending on the Convar settings below) and you will also get a new Player to protect.

If you damage the Person you should protect, he will get less damage and you will get much damage back (Depending on the convar settings below). If you manage to kill the Person you need to protect somehow, you will also die (Depending on the convar settings below).


## Convars

Besides the normal role convars found in ULX, there are these special convars:

```
# the damage a bodyguard will get if the person he needs to protect dies
  ttt_bodygrd_damage_guarded_death [0..n] (def: 20)
# defines if the bodyguard should be killed if he manages to kill the person he needs to protect
  ttt_bodygrd_kill_guard_teamkill [0/1] (def: 1)
# the multiplier of damage that gets reflected to the bodyguard if damaging the person he needs to protect
  ttt_bodygrd_damage_reflect_multiplier [0..n] (def: 1.5)
# the multiplier of damage that the person will get if damaged by his bodyguard
  ttt_bodygrd_damage_dealt_multiplier [0..n] (def: 0.1)
```
