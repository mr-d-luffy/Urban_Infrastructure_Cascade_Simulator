# 04 — Mathematical Model & Cascade Propagation Formulas

The **Urban Infrastructure Cascade Simulator** mathematically models a smart city as a directed dependency network.

---

## 1. Graph Definition

The city is represented by a directed graph:
\[
G = (V, E)
\]
Where:
- \( V \): Set of municipal infrastructure services (e.g., \( V = \{\text{Power}, \text{Water}, \text{Hospital}, \text{Transport}, \dots\} \)).
- \( E \): Set of directed dependency pairs \( (u, v) \) where \( v \) depends upon \( u \).
- \( w_{u \to v} \in (0, 1] \): Weight/strength of the dependency of \( v \) on \( u \).

---

## 2. Upstream Stress Calculation

At any simulation tick \( t \), the cumulative stress experienced by a service \( v \) due to failure or degradation in its upstream dependencies is defined as:

\[
\text{Stress}(v, t) = \sum_{u \in \text{Upstream}(v)} w_{u \to v} \cdot C(\text{State}(u, t))
\]

Where the **Stress Contribution Coefficient** \( C(\text{State}) \) is defined as:

\[
C(\text{State}) = \begin{cases} 
1.0 & \text{if } \text{State} = \text{FAILED} \\
0.5 & \text{if } \text{State} = \text{DEGRADED} \\
0.25 & \text{if } \text{State} = \text{RECOVERING} \\
0.0 & \text{if } \text{State} \in \{\text{HEALTHY}, \text{RECOVERED}\}
\end{cases}
\]

---

## 3. State Evaluation Thresholds

During each tick evaluation, the target service's state is updated according to the following deterministic rules:

1. **Failure Condition:**
   \[
   \text{Stress}(v, t) \ge 1.0 \implies \text{State}(v, t) \to \text{FAILED}
   \]
2. **Degradation Condition:**
   \[
   0.5 \le \text{Stress}(v, t) < 1.0 \quad \text{and} \quad \text{State}(v, t-1) = \text{HEALTHY} \implies \text{State}(v, t) \to \text{DEGRADED}
   \]
3. **Healing / De-escalation Condition (when upstream recovers):**
   \[
   \text{Stress}(v, t) < 0.5 \quad \text{and} \quad \text{State}(v, t-1) = \text{DEGRADED} \implies \text{State}(v, t) \to \text{HEALTHY}
   \]

---

## 4. Cascade Depth Metric (Shortest-Path BFS)

Let \( R \subseteq V \) be the set of root disrupted services (disruptions applied externally at \( T=0 \)), and let \( A \subseteq V \) be the set of all services that experienced failure or degradation during the simulation.

The **Cascade Depth** is computed as the maximum shortest-path distance in the directed graph from any root node to any affected node:

\[
\text{Cascade Depth} = \max_{a \in A} \left( \min_{r \in R} \text{dist}_G(r, a) \right)
\]

Where:
- \(\text{dist}_G(r, a)\) is the length of the shortest directed path from \( r \) to \( a \).
- If \( A = R \), \(\text{Cascade Depth} = 0\) (disruptions were contained locally).

---

## 5. System Impact Percentage

\[
\text{System Impact } \% = \left( \frac{|A|}{|V|} \right) \times 100
\]

---

## 6. Stabilization Condition

The simulation terminates when no state transitions occur for 3 consecutive simulation ticks:

\[
\Delta \text{State}(t) = 0 \quad \text{for } t \in [T_{\text{stable}} - 2, T_{\text{stable}}]
\]
Or when \( t \ge \text{durationSeconds} \).
