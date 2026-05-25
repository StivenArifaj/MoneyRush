import 'dart:math';

// Pure functions only — no state, no side effects.
// All financial calculations for the simulation engine live here.
class FinancialMath {
  static final _rng = Random();

  // ── Rounding ──────────────────────────────────────────────────────────────

  static double round2(double value) =>
      (value * 100).roundToDouble() / 100;

  // ── Interest ──────────────────────────────────────────────────────────────

  // Compound interest for one period (month by default)
  static double compoundInterest({
    required double principal,
    required double annualRate,
    int periodsPerYear = 12,
  }) {
    final periodRate = annualRate / periodsPerYear;
    return round2(principal * periodRate);
  }

  // Remaining loan balance after [paymentsMade] payments
  static double loanRemainingBalance({
    required double principal,
    required double annualRate,
    required int totalMonths,
    required int paymentsMade,
  }) {
    if (annualRate == 0) {
      return round2(
          principal * (1 - paymentsMade / totalMonths));
    }
    final r = annualRate / 12;
    final balance =
        principal * (pow(1 + r, totalMonths) - pow(1 + r, paymentsMade)) /
            (pow(1 + r, totalMonths) - 1);
    return round2(balance.clamp(0, double.infinity));
  }

  // Fixed monthly payment for a loan
  static double monthlyPayment({
    required double principal,
    required double annualRate,
    required int months,
  }) {
    if (annualRate == 0) return round2(principal / months);
    final r = annualRate / 12;
    final payment = principal * (r * pow(1 + r, months)) / (pow(1 + r, months) - 1);
    return round2(payment);
  }

  // ── Net Worth ─────────────────────────────────────────────────────────────

  static double netWorth({
    required double bankBalance,
    required double savingsBalance,
    required double investmentValue,
    required double propertyValue,
    required double debtBalance,
    required double creditCardBalance,
  }) {
    final assets = bankBalance + savingsBalance + investmentValue + propertyValue;
    final liabilities = debtBalance + creditCardBalance;
    return round2(assets - liabilities);
  }

  // ── Investment Simulation ─────────────────────────────────────────────────

  // Monthly investment return using normally distributed random walk
  static double monthlyInvestmentReturn({
    required double portfolioValue,
    double annualMean = 0.10,
    double annualStdDev = 0.15,
  }) {
    final monthlyMean = annualMean / 12;
    final monthlyStd = annualStdDev / sqrt(12);
    final z = _gaussianRandom();
    final returnRate = monthlyMean + monthlyStd * z;
    // Cap single-month loss at -30% of portfolio
    final clampedReturn = returnRate.clamp(-0.30, 0.30);
    return round2(portfolioValue * clampedReturn);
  }

  // Box-Muller transform for Gaussian random number
  static double _gaussianRandom() {
    final u1 = _rng.nextDouble();
    final u2 = _rng.nextDouble();
    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }

  // ── Scores ────────────────────────────────────────────────────────────────

  // Wealth score: net worth relative to expected for life stage
  static int wealthScore({
    required double netWorth,
    required int inGameAgeYears,
    required double annualIncome,
  }) {
    // Rule of thumb: net worth should be ~1x income by 30, grows from there
    final yearsWorking = (inGameAgeYears - 18).clamp(0, 50);
    final target = annualIncome * (yearsWorking / 12.0);
    if (target <= 0) return 50;
    final ratio = netWorth / target;
    return (ratio * 50).clamp(0, 100).round();
  }

  // Stability score: emergency fund + low debt ratio
  static int stabilityScore({
    required double emergencyFund,
    required double monthlyExpenses,
    required double debtBalance,
    required double annualIncome,
  }) {
    final efMonths = monthlyExpenses > 0
        ? (emergencyFund / monthlyExpenses).clamp(0.0, 6.0)
        : 0.0;
    final efScore = (efMonths / 6.0) * 60;

    final debtRatio = annualIncome > 0
        ? (debtBalance / annualIncome).clamp(0.0, 2.0)
        : 2.0;
    final debtScore = (1 - debtRatio / 2.0) * 40;

    return (efScore + debtScore).clamp(0, 100).round();
  }

  // Growth score: is net worth growing and income diversifying?
  static int growthScore({
    required double investmentPortfolioValue,
    required double netWorth,
    required int incomeStreamCount,
  }) {
    final investingRatio = netWorth > 0
        ? (investmentPortfolioValue / netWorth).clamp(0.0, 0.5)
        : 0.0;
    final investingScore = (investingRatio / 0.5) * 60;
    final streamScore = (incomeStreamCount.clamp(1, 4) / 4.0) * 40;
    return (investingScore + streamScore).clamp(0, 100).round();
  }

  // Freedom score: low debt-to-income ratio
  static int freedomScore({
    required double monthlyDebtPayments,
    required double monthlyIncome,
  }) {
    if (monthlyIncome <= 0) return 0;
    final dti = (monthlyDebtPayments / monthlyIncome).clamp(0.0, 1.0);
    return ((1.0 - dti) * 100).clamp(0, 100).round();
  }

  // Wellbeing score: spending some on quality of life
  static int wellbeingScore({
    required double leisureSpending,
    required double monthlyIncome,
  }) {
    if (monthlyIncome <= 0) return 50;
    final ratio = (leisureSpending / monthlyIncome).clamp(0.0, 0.20);
    // Sweet spot: 5–15% of income on wellbeing
    if (ratio >= 0.05 && ratio <= 0.15) return 100;
    if (ratio < 0.05) return ((ratio / 0.05) * 80).round();
    return (80 - ((ratio - 0.15) / 0.05) * 30).clamp(0, 100).round();
  }

  // Life score: weighted average of all five dimensions
  static int lifeScore({
    required int wealth,
    required int stability,
    required int growth,
    required int freedom,
    required int wellbeing,
  }) {
    return ((wealth * 0.25 +
                stability * 0.25 +
                growth * 0.20 +
                freedom * 0.20 +
                wellbeing * 0.10))
        .clamp(0, 100)
        .round();
  }

  // ── Tax Estimation ────────────────────────────────────────────────────────

  // Simplified US-style marginal tax on annual income
  static double estimateAnnualTax(double annualIncome) {
    if (annualIncome <= 11600) return round2(annualIncome * 0.10);
    if (annualIncome <= 47150) return round2(1160 + (annualIncome - 11600) * 0.12);
    if (annualIncome <= 100525) return round2(5426 + (annualIncome - 47150) * 0.22);
    return round2(17168.5 + (annualIncome - 100525) * 0.24);
  }

  // Self-employment adds ~15.3% for FICA
  static double selfEmploymentTaxSurcharge(double netProfit) =>
      round2(netProfit * 0.153 * 0.9235);
}
