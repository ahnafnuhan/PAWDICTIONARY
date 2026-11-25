import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = "https://huqlhlxukomrozoymvdh.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_dPY3CDRcFiCKG3HStHQbOA_w6mBHuBR";
const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY);

const navLinks = document.querySelector(".nav-links");

function removeAuthenticationLinks() {
    if (!navLinks) return;

    navLinks.querySelectorAll("li").forEach((item) => {
        const link = item.querySelector("a");
        if (!link) return;

        const href = link.getAttribute("href") || "";
        const label = link.textContent.trim();
        if (
            href === "auth.html#signin"
            || href === "auth.html#signup"
            || label === "Sign In"
            || label === "Sign Up"
        ) {
            item.remove();
        }
    });
}

function ensureUserLogo(session) {
    if (!navLinks) return;

    const userMetadata = session.user.user_metadata || {};
    const name = userMetadata.name || userMetadata.full_name || "User";
    const avatarUrl = userMetadata.avatar_url;
    let existingUserLink = navLinks.querySelector(".nav-user");

    if (!existingUserLink) {
        existingUserLink = document.createElement("li");
        existingUserLink.className = "nav-user";
        navLinks.appendChild(existingUserLink);
    }

    existingUserLink.innerHTML = avatarUrl
        ? `<a href="account.html" class="user-logo" aria-label="Open account for ${name}" title="${name}">
                <img src="${avatarUrl}" alt="">
           </a>`
        : `<a href="account.html" class="user-logo" aria-label="Open account for ${name}" title="${name}">
                <svg aria-hidden="true" viewBox="0 0 24 24">
                    <circle cx="12" cy="8" r="4"></circle>
                    <path d="M4 21a8 8 0 0 1 16 0"></path>
                </svg>
           </a>`;
}

async function updateNavigation() {
    const { data: { session } } = await supabase.auth.getSession();

    if (!session) {
        document.querySelector(".nav-user")?.remove();
        return;
    }

    removeAuthenticationLinks();
    ensureUserLogo(session);
}

updateNavigation();

supabase.auth.onAuthStateChange((_event, session) => {
    if (session) {
        updateNavigation();
    } else {
        document.querySelector(".nav-user")?.remove();
    }
});
