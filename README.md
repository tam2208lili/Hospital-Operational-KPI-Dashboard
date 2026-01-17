# 🏥 Hospital Operational Performance Analysis

## 📌 Project Overview
This project provides an end-to-end data analysis of hospital operations and financial performance from 2022 to 2025. By integrating **SQL** for data processing and **Tableau** for visualization, the study identifies critical bottlenecks in patient conversion, staffing inefficiencies, and revenue optimization strategies.

## 📂 Data Source
* **Source:** [Kaggle Hospital Management System](https://www.kaggle.com/datasets/mshamoonbutt/hospital-management-system)
* **Description:** The dataset includes patient medical records, treatment costs, staffing data, and surgical schedules.

## 🛠 Tech Stack
* **SQL:** Data cleaning, transformation, and KPI calculation.
* **Tableau:** Interactive dashboards for executive, operational, and demographic analysis.

## 📂 Project Structure
* `data/raw_data/`: Original dataset retrieved from Kaggle.
* `data/processed_data/`: Cleaned and transformed data ready for Tableau upload.
* `scripts/`: SQL scripts used for data processing and KPI extraction.
* `images/`: Screenshots of the 5 specialized dashboards.
* `README.md`: Project documentation and strategic analysis.

---

## 📊 Key Insights & Strategic Analysis

### 1. Executive Overview: Capacity Utilization & Revenue Concentration
* **Finding (Data-backed):** Monthly inpatient volume remains modest (under 160 patients/month), with an average **Length of Stay (LOS) of 4.6 days**, resulting in relatively low bed turnover. While total admissions increased by only **15.9%**, total revenue surged by **30.4%**, primarily driven by **Critical Care** (9% of admissions but a disproportionate revenue contributor), followed by Cardiology and Family Medicine.
* **Operational Risk:** Revenue growth is case-mix driven rather than volume-driven, increasing exposure to fluctuations in high-acuity cases and insurance reimbursement policies. Moderate LOS combined with low throughput suggests **under-utilized bed capacity**, limiting scalable revenue growth.
* **Strategic Recommendation:** Shift growth strategy toward volume-stabilizing service lines (e.g., Cardiology and Family Medicine) by introducing premium screening and chronic care packages to improve bed-day productivity and smooth revenue volatility.

### 2. Staffing Efficiency: Structural Overcapacity in Nursing Resources
* **Finding (Data-backed):** The calculated **Patient-to-Nurse ratio** is critically low, ranging from **0.03 to 0.22 (average 0.104)**, based on concurrent inpatient volume relative to total nursing staff on duty.
* **Operational Risk:** This indicates systematic **under-utilization of nursing capacity**, leading to high fixed labor costs without proportional clinical output. Persistently low utilization erodes operating margins and reduces financial flexibility.
* **Strategic Recommendation:** Adopt a **flexible staffing model** by reallocating excess nursing capacity toward outpatient services, preventive care programs, or premium home-care offerings—converting idle labor capacity into revenue-generating activities while preserving care quality.

### 3. Admission Funnel: Outpatient-to-Inpatient Leakage
* **Finding (Data-backed):** The inpatient conversion rate is critically low at **0.9%**, compounded by a **10.2% no-show rate** and a 79% consultation completion rate. Only five departments consistently complete appointments, with General Medicine and Cardiology leading in online booking performance.
* **Operational Risk:** Significant **leakage across the admission funnel** indicates that marketing and outpatient engagement efforts are not translating into inpatient demand, reducing ROI on acquisition costs and under-utilizing inpatient capacity.
* **Strategic Recommendation:** Implement **automated SMS/email reminder systems** to reduce no-shows and redesign digital booking flows for underperforming departments. Even marginal improvements in conversion could yield high ROI given existing excess capacity.

### 4. Surgical Services: Fragmented Utilization & Continuity Risk
* **Finding (Data-backed):** Between 2022–2025, approximately **1,000 surgeries** were performed by **37 surgeons**. High-cost specialties (Emergency, Thoracic, Maxillofacial) are dependent on a **single physician each**, performing fewer than 40 cases over three years.
* **Operational Risk:** Low surgical volume per surgeon leads to poor utilization of operating rooms (OR). Reliance on single specialists creates a **Single Point of Failure**, threatening service continuity and revenue stability.
* **Strategic Recommendation:** Strengthen referral networks and introduce **cross-specialty training** to increase surgical throughput, improve OR utilization, and mitigate operational risk while maximizing return on high fixed-cost infrastructure.

### 5. Demographics & Payer Mix: Insurance Dependence Risk
* **Finding (Data-backed):** The dominant patient group is aged **18–60**. Despite being the most economically active demographic, this group relies predominantly on **insurance-based payments** with limited direct self-pay utilization.
* **Operational Risk:** Heavy dependence on third-party payers exposes the hospital to **reimbursement delays**, policy shifts, and cash flow instability—particularly within its core patient demographic.
* **Strategic Recommendation:** Design **self-pay and premium diagnostic packages** tailored to the 18–60 demographic to diversify revenue streams, accelerate cash inflows, and reduce payer concentration risk.

---

### 🚀 Live Dashboard
View the interactive visualization here: **[Dashboard](https://public.tableau.com/views/Hospital-Operational-KPI-Dashboard/Dashboard1?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link)**

