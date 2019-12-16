import 'dart:convert';
import 'dart:math' as math;

class MoonPhase {
  // Phases of the moon & precision
  static const int NEW = 0;
  static const int FIRST = 1;
  static const int FULL = 2;
  static const int LAST = 3;
  static const int PHASE_MASK = 3;

  // Astronomical Constants
  // Semi-major axis of Earth's orbit, in kilometers
  static const SUN_SMAXIS = 1.49585e8;

  // SUN_SMAXIS premultiplied by the angular size of the Sun from the Earth
  static const SUN_ANGULAR_SIZE_SMAXIS = SUN_SMAXIS * 0.533128;

  // Semi-major axis of the Moon's orbit, in kilometers
  static const MOON_SMAXIS = 384401.0;

  // MOON_SMAXIS premultiplied by the angular size of the Moon from the Earth
  static const MOON_ANGULAR_SIZE_SMAXIS = MOON_SMAXIS * 0.5181;

  // Synodic month (new Moon to new Moon), in days
  static const SYNODIC_MONTH = 29.53058868;

  torad(d) {
    return (math.pi / 180.0) * d;
  }

  phase(DateTime _date) {
    // Testing Dates;
    //DateTime date = DateTime(2019, 12, 26);

    DateTime date = _date;
    // t is the time in "Julian centuries" of 36525 days starting from 2000-01-01
    // (Note the 0.3 is because the UNIX epoch is on 1970-01-01 and that's 3/10th
    // of a century before 2000-01-01, which I find cute :3 )
    double t =
        date.millisecondsSinceEpoch.toDouble() * (1 / 3155760000000) - 0.3;

    // lunar mean elongation (Astronomical Algorithms, 2nd ed., p. 338)
    double d = 297.8501921 +
        t *
            (445267.1114034 +
                t * (-0.0018819 + t * ((1 / 545868) + t * (-1 / 113065000))));

    // solar mean anomaly (p. 338)
    double m = 357.5291092 +
        t * (35999.0502909 + t * (-0.0001536 + t * (1 / 24490000)));

    // lunar mean anomaly (p. 338)
    double n = 134.9633964 +
        t *
            (477198.8675055 +
                t * (0.0087414 + t * ((1 / 69699) + t * (-1 / 14712000))));

    // derive sines and cosines necessary for the below calculations
    double sind = math.sin(torad(d));

    double sinm = math.sin(torad(m));
    double sinn = math.sin(torad(n));
    double cosd = math.cos(torad(d));
    double cosm = math.cos(torad(m));
    double cosn = math.cos(torad(n));

    // use trigonometric identities to derive the remainder of the sines and
    // cosines we need. this reduces us from needing 14 sin/cos calls to only 7,
    // and makes the lunar distance and solar distance essentially free.
    // http://mathworld.wolfram.com/Double-AngleFormulas.html
    // http://mathworld.wolfram.com/TrigonometricAdditionFormulas.html
    double sin2d = 2 * sind * cosd; // sin(2d)
    double sin2n = 2 * sinn * cosn; // sin(2n)
    double cos2d = 2 * cosd * cosd - 1; // cos(2d)
    double cos2m = 2 * cosm * cosm - 1; // cos(2m)
    double cos2n = 2 * cosn * cosn - 1; // cos(2n)
    double sin2dn = sin2d * cosn - cos2d * sinn; // sin(2d - n)
    double cos2dn = cos2d * cosn + sin2d * sinn; // cos(2d - n)

    // lunar phase angle (p. 346)
    double i = 180 -
        d -
        6.289 * sinn +
        2.100 * sinm -
        1.274 * sin2dn -
        0.658 * sin2d -
        0.214 * sin2n -
        0.110 * sind;

    // fractional illumination (p. 345)
    double illumination = math.cos(torad(n)) * 0.5 + 0.5;

    // fractional lunar phase
    double phase = 0.5 - i * (1 / 360);
    phase -= phase.floor();

    // lunar distance (p. 339-342)
    // XXX: the book is not clear on how many terms to use for a given level of
    // accuracy! I used all the easy ones that we already have for free above,
    // but I imagine this is more than necessary...
    //double moonDistance = 385000.56 - 20905.355 * cosn - 3699.111 * cos2dn - 2955.968 * cos2d - 569.925 * cos2n + 108.743 * cosd;

    // solar distance
    // https://aa.usno.navy.mil/faq/docs/SunApprox.php
    //double sunDistance = tokm(1.00014 - 0.01671 * cosm - 0.00014 * cos2m);

    // set To int for switch
    List result = [
      (double.parse(phase.toStringAsFixed(1)) * 10).round(),
      illumination
    ];
    return result;
  }
}
