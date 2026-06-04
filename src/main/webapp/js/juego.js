document.querySelectorAll(".carta").forEach(function(carta) {
  var rotX  = gsap.quickTo(carta, "rotationX", { ease: "power3", duration: 0.4 });
  var rotY  = gsap.quickTo(carta, "rotationY", { ease: "power3", duration: 0.4 });
  var moveY = gsap.quickTo(carta, "y",         { ease: "power3", duration: 0.4 });

  carta.addEventListener("pointermove", function(e) {
    var rect = carta.getBoundingClientRect();
    var x = (e.clientX - rect.left)  / rect.width;
    var y = (e.clientY - rect.top)   / rect.height;
    rotX(gsap.utils.interpolate(15, -15, y));
    rotY(gsap.utils.interpolate(-15, 15, x));
    moveY(-12);
  });

  carta.addEventListener("pointerleave", function() {
    rotX(0);
    rotY(0);
    moveY(0);
  });
});
