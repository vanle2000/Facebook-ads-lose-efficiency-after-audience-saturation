#!/usr/bin/env python3
"""Recompute every headline number in reports/executive_summary.md from the data.

Run:  python scripts/compute_summary.py
Source: data/raw/Facebook_ads_KAG.csv (the Kaggle "sales conversion" set,
1,143 ads). This script is the source of truth for the summary; if the two ever
disagree, the data wins.
"""
from __future__ import annotations

import pathlib

import numpy as np
import pandas as pd

DATA = pathlib.Path(__file__).resolve().parents[1] / "data" / "raw" / "Facebook_ads_KAG.csv"


def main() -> None:
    df = pd.read_csv(DATA)
    df.columns = [c.strip() for c in df.columns]

    n = len(df)
    spend = df["Spent"].sum()
    clicks = df["Clicks"].sum()
    impr = df["Impressions"].sum()
    appr = df["Approved_Conversion"].sum()
    cpa = spend / appr
    ctr = clicks / impr * 100
    conv_rate = appr / clicks * 100

    zero = df[df["Approved_Conversion"] == 0]
    waste_spend = zero["Spent"].sum()

    seg = (
        df.groupby("interest")
        .agg(spent=("Spent", "sum"), appr=("Approved_Conversion", "sum"))
        .assign(cpa=lambda d: d["spent"] / d["appr"].replace(0, np.nan))
    )

    print(f"Ads                              : {n:,}")
    print(f"Total spend                      : ${spend:,.0f}")
    print(f"Approved conversions             : {int(appr):,}")
    print(f"Overall CPA                      : ${cpa:,.2f}")
    print(f"Average CTR                      : {ctr:.3f}%")
    print(f"Conversion rate (approved/clicks): {conv_rate:.2f}%")
    print()
    print(f"Ads with 0 approved conversions  : {len(zero):,} ({len(zero)/n*100:.1f}%)")
    print(f"Budget on those zero-conv ads    : ${waste_spend:,.0f} ({waste_spend/spend*100:.1f}%)")
    print()
    print("CPA by age group:")
    print(
        df.groupby("age")
        .apply(lambda x: x["Spent"].sum() / max(x["Approved_Conversion"].sum(), 1), include_groups=False)
        .round(2)
        .to_string()
    )
    print()
    print("CPA by gender:")
    print(
        df.groupby("gender")
        .apply(lambda x: x["Spent"].sum() / max(x["Approved_Conversion"].sum(), 1), include_groups=False)
        .round(2)
        .to_string()
    )
    print()
    print(
        f"Interest-segment CPA range       : ${seg['cpa'].min():.2f} - ${seg['cpa'].max():.2f} "
        f"(median ${seg['cpa'].median():.2f}, CV {seg['cpa'].std()/seg['cpa'].mean():.2f})"
    )


if __name__ == "__main__":
    main()
