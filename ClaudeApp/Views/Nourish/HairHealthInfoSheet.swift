import SwiftUI

struct HairHealthInfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    // Hero
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "comb.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.appSoftBrown)

                        Text("Hair & Hormones")
                            .warmTitle()

                        Text("Your hair follicles and ovaries are deeply connected — they share the same hormonal signals, need the same mitochondrial energy, and respond to the same circulation and stress patterns.")
                            .guidanceText()
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, AppTheme.Spacing.sm)

                    // Sections
                    infoSection(
                        icon: "dna",
                        title: "Shared Hormonal Control",
                        body: "Your ovaries produce estrogen, progesterone, and androgens — hormones that also regulate your hair follicles directly.\n\nEstrogen keeps hair in its growth phase (anagen), making it thicker and fuller. Progesterone supports hair retention and buffers androgen effects. When ovarian reserve declines, these hormones shift — and hair often shows it first: increased shedding, thinner strands, slower regrowth, and a widening part line.\n\nSome women notice hair changes months before their cycle becomes irregular. Hair is one of the body's earliest hormonal messengers."
                    )

                    infoSection(
                        icon: "clock.arrow.2.circlepath",
                        title: "Shared Biological Clocks",
                        body: "Both ovaries and hair follicles are cycling organs. They rely on mitochondrial energy, healthy blood flow, and stable hormone signaling to function well.\n\nWhen ovarian reserve drops — fewer viable eggs remain — it's often accompanied by reduced mitochondrial activity. This same slowdown can weaken hair growth. The biological clock that governs egg quality also influences follicle vitality."
                    )

                    infoSection(
                        icon: "testtube.2",
                        title: "Key Hormones That Connect Both",
                        body: "Estrogen prolongs the hair growth phase. Progesterone buffers androgen-driven thinning. Thyroid hormones influence both ovulation and hair cycles. DHEA supports ovarian reserve and follicle health simultaneously. Cortisol from chronic stress disrupts both systems.\n\nWhen hormonal balance shifts — even subtly — hair changes can appear long before cycle irregularity."
                    )

                    infoSection(
                        icon: "arrow.triangle.branch",
                        title: "Why Early Ovarian Decline Affects Hair",
                        body: "When ovarian reserve drops earlier than expected:\n\n• Estrogen dips — hair growth slows\n• Progesterone dips — follicles become more androgen-sensitive\n• Higher androgen effect — thinning on crown and temples\n• Reduced circulation — follicles miniaturize\n\nThis is why some women notice hair thinning as one of the very first signs of hormonal change."
                    )

                    infoSection(
                        icon: "drop.circle",
                        title: "Beyond Hormones: Circulation & Inflammation",
                        body: "Both ovaries and hair follicles depend on strong microcirculation. Poor blood flow, chronic inflammation, or nutritional deficits in iron, zinc, protein, and vitamin D can accelerate aging in both systems.\n\nSimple practices like daily scalp massage, walking after meals, and hip mobility work improve blood flow to both the scalp and pelvis — nourishing follicles from both ends."
                    )

                    infoSection(
                        icon: "heart.circle",
                        title: "Can Supporting Ovaries Help Hair?",
                        body: "Yes. Supporting mitochondrial health, balancing hormones, improving circulation, managing stress, and ensuring key nutrients — these strategies can improve hair density and potentially slow ovarian decline simultaneously.\n\nThe Hair Health protocol in this app is designed around this principle: what nourishes one system nourishes the other."
                    )

                    // The common pattern
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundStyle(Color.appRose)
                            Text("The Pattern Many Women See")
                                .warmHeadline()
                        }

                        Text("Increased stress \u{2192} disrupted sleep & cortisol \u{2192} lower estrogen \u{2192} thinner hair \u{2192} irregular cycle \u{2192} more stress \u{2192} the cycle continues.\n\nBreaking this loop early — through nourishment, rest, and cycle-aligned care — is often the most effective strategy for both hair and hormonal health.")
                            .guidanceText()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .warmCard()

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(Color.appCream.ignoresSafeArea())
            .navigationTitle("Hair Health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                    }
                }
            }
        }
    }

    private func infoSection(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundStyle(Color.appSoftBrown)
                Text(title)
                    .warmHeadline()
            }

            Text(body)
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
    }
}
