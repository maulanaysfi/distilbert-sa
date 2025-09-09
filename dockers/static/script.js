document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('predictForm');
    const textarea = document.getElementById('textInput');
    const result = document.getElementById('result');
    const submitButton = form.querySelector('button[type="submit"]');

    form.addEventListener('submit', async (event) => {
        event.preventDefault();

        const text = textarea.value.trim();
        if (!text) {
            result.textContent = 'Please enter some text.';
            result.classList.remove('hidden');
            result.className = 'mt-6 text-xl font-semibold text-center text-red-600';
            return;
        }

        try {
            submitButton.disabled = true;
            submitButton.classList.add('opacity-60', 'cursor-not-allowed');

            result.textContent = 'Analyzing...';
            result.classList.remove('hidden');
            result.className = 'mt-6 text-xl font-semibold text-center text-gray-600';

            const response = await fetch('/predict', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ text })
            });

            if (!response.ok) {
                throw new Error(`Request failed with status ${response.status}`);
            }

            const data = await response.json();
            const label = data.class;

            let colorClass = 'text-gray-700';
            if (label === 'positive') colorClass = 'text-green-600';
            else if (label === 'negative') colorClass = 'text-red-600';

            result.className = `mt-6 text-xl font-semibold text-center ${colorClass}`;
            result.textContent = `Prediction: ${label}`;
        } catch (error) {
            console.error(error);
            result.className = 'mt-6 text-xl font-semibold text-center text-red-600';
            result.textContent = 'Error analyzing text. Please try again.';
        } finally {
            submitButton.disabled = false;
            submitButton.classList.remove('opacity-60', 'cursor-not-allowed');
        }
    });
});

